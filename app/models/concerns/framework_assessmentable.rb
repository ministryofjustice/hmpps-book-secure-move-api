module FrameworkAssessmentable
  extend ActiveSupport::Concern
  include StateMachineable

  ASSESSMENT_NOT_STARTED = 'not_started'.freeze
  ASSESSMENT_IN_PROGRESS = 'in_progress'.freeze
  ASSESSMENT_COMPLETED = 'completed'.freeze
  ASSESSMENT_CONFIRMED = 'confirmed'.freeze

  included do
    # "not_started" cannot be used as the name of the enum due to warnings in the model
    # that it starts with a "not_".
    enum statuses: {
      unstarted: ASSESSMENT_NOT_STARTED,
      in_progress: ASSESSMENT_IN_PROGRESS,
      completed: ASSESSMENT_COMPLETED,
      confirmed: ASSESSMENT_CONFIRMED,
    }

    validates :status, presence: true, inclusion: { in: statuses }
    validates :profile, uniqueness: true
    validates :confirmed_at, presence: { if: :confirmed? }

    has_many :framework_responses, as: :assessmentable, dependent: :destroy
    has_many :generic_events, as: :eventable, dependent: :destroy

    belongs_to :framework
    has_many :framework_questions, through: :framework
    has_many :framework_flags, through: :framework_responses
    belongs_to :profile

    has_state_machine FrameworkAssessmentStateMachine, on: :status

    delegate :calculate,
             :confirm,
             :unstarted?,
             :in_progress?,
             :completed?,
             :confirmed?,
             to: :state_machine
  end

  def build_responses!
    ApplicationRecord.retriable_transaction do
      self.prefill_source = previous_assessment

      questions = framework_questions.includes(:dependents).index_by(&:id)
      questions.each_value do |question|
        next unless question.parent_id.nil?

        question.build_responses(assessmentable: self, questions: questions, previous_responses: previous_responses).save!
      end

      self.section_progress = calculate_section_progress(responses: framework_responses)
      save!
    end

    self
  end

  def import_nomis_mappings!
    return unless move&.from_location&.prison?

    FrameworkNomisMappings::Importer.new(assessmentable: self).call
  end

  def calculate_section_progress(responses: required_responses)
    responses.group_by(&:section).map do |section, section_responses|
      {
        key: section,
        status: set_progress(section_responses),
      }
    end
  end

  def update_status_and_progress!
    self.section_progress = calculate_section_progress
    progress = set_progress(required_responses)
    state_machine.calculate!(progress)

    save!
  end

  def confirm!(new_status, handover_details = nil, handover_occurred_at = nil)
    return unless new_status == ASSESSMENT_CONFIRMED

    state_machine.confirm! unless state_machine.confirmed? && (handover_details.present? || handover_occurred_at.present?)
    self.handover_details = handover_details if handover_details.present? && respond_to?(:handover_details)
    self.handover_occurred_at = handover_occurred_at if handover_occurred_at.present? && respond_to?(:handover_occurred_at)
    save!
  rescue FiniteMachine::InvalidStateError
    errors.add(:status, :invalid_status, message: "can't update to '#{new_status}' from '#{status}'")
    raise ActiveRecord::RecordInvalid, self
  end

  def handle_event_run(dry_run: false)
    save! if changed? && valid? && !dry_run
  end

  def editable?
    return false if confirmed?

    move_status_editable?
  end

  class_methods do
    def save_with_responses!(version: nil, move_id: nil)
      move = Move.find(move_id)
      profile = move.profile

      framework = Framework.find_by!(version: version, name: framework_name)

      record = new(profile: profile, move: move, framework: framework)
      record.build_responses!
      record.import_nomis_mappings!

      record
    rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
      record.errors.add(:profile, :taken)
      raise ActiveRecord::RecordInvalid, record
    end

  private

    def framework_name
      raise NotImplementedError
    end
  end

  def set_progress(responses)
    responded = responses.pluck(:responded)

    return ASSESSMENT_COMPLETED if responded.all?(true)
    return ASSESSMENT_NOT_STARTED if responded.all?(false)

    ASSESSMENT_IN_PROGRESS
  end

  def required_responses
    @required_responses ||= framework_responses.includes(:framework_question, :parent).select do |framework_response|
      framework_response.parent ? framework_response.parent.option_selected?(framework_response.framework_question.dependent_value) : framework_response
    end
  end

  def previous_assessment
    raise NotImplementedError
  end

  def previous_responses
    @previous_responses ||= begin
      return {} unless prefill_source

      prefill_source.framework_responses.includes(framework_question: :dependents).each_with_object({}) do |response, hash|
        value = response.prefill_value
        next if value.blank?

        hash[response.framework_question.key] = value
      end
    end
  end

  def move_status_editable?
    return true if move.blank?

    move.requested? || move.booked?
  end

  def responded_by(before_datetime = Time.zone.now)
    framework_responses.order(:created_at).where(created_at: Time.zone.at(0)..before_datetime).each_with_object({}) do |framework_response, hash|
      hash[framework_response.section] ||= []
      next if hash[framework_response.section].include?(framework_response.responded_by)

      hash[framework_response.section] << framework_response.responded_by
    end
  end
end
