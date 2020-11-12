class PersonEscortRecord < VersionedModel
  include StateMachineable

  # "not_started" cannot be used as the name of the enum due to warnings in the model
  # that it starts with a "not_".
  PERSON_ESCORT_RECORD_NOT_STARTED = 'not_started'.freeze
  PERSON_ESCORT_RECORD_IN_PROGRESS = 'in_progress'.freeze
  PERSON_ESCORT_RECORD_COMPLETED = 'completed'.freeze
  PERSON_ESCORT_RECORD_CONFIRMED = 'confirmed'.freeze

  enum statuses: {
    unstarted: PERSON_ESCORT_RECORD_NOT_STARTED,
    in_progress: PERSON_ESCORT_RECORD_IN_PROGRESS,
    completed: PERSON_ESCORT_RECORD_COMPLETED,
    confirmed: PERSON_ESCORT_RECORD_CONFIRMED,
  }

  validates :status, presence: true, inclusion: { in: statuses }
  validates :profile, uniqueness: true
  validates :confirmed_at, presence: { if: :confirmed? }

  has_many :framework_responses, as: :assessmentable, dependent: :destroy
  has_many :generic_events, as: :eventable, dependent: :destroy # NB: polymorphic association

  belongs_to :framework
  has_many :framework_questions, through: :framework
  has_many :framework_flags, through: :framework_responses
  belongs_to :profile
  belongs_to :move, optional: true
  belongs_to :prefill_source, class_name: 'PersonEscortRecord', optional: true

  has_state_machine PersonEscortRecordStateMachine, on: :status

  delegate :calculate,
           :confirm,
           :unstarted?,
           :in_progress?,
           :completed?,
           :confirmed?,
           to: :state_machine

  def self.save_with_responses!(version: nil, move_id: nil)
    move = Move.find(move_id)
    profile = move.profile

    framework = Framework.find_by!(version: version)

    record = new(profile: profile, move: move, framework: framework)
    record.build_responses!
    record.import_nomis_mappings!

    record
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    record.errors.add(:profile, :taken)
    raise ActiveRecord::RecordInvalid, record
  end

  def build_responses!
    ApplicationRecord.retriable_transaction do
      self.prefill_source = previous_per
      save!

      questions = framework_questions.includes(:dependents).index_by(&:id)
      questions.values.each do |question|
        next unless question.parent_id.nil?

        response = question.build_responses(assessmentable: self, questions: questions, previous_responses: previous_responses)
        framework_responses.build(response.slice(:type, :framework_question, :dependents, :value, :prefilled, :person_escort_record, :assessmentable))
      end

      PersonEscortRecord.import([self], validate: false, recursive: true, all_or_none: true, validate_uniqueness: true, on_duplicate_key_update: { conflict_target: [:id] })
    end

    self
  end

  def import_nomis_mappings!
    return unless move&.from_location&.prison?

    FrameworkNomisMappings::Importer.new(person_escort_record: self).call
  end

  def section_progress
    sections_to_responded.group_by(&:section).map do |section, responses|
      {
        key: section,
        status: set_progress(responses),
      }
    end
  end

  def update_status!
    progress = set_progress(sections_to_responded)
    state_machine.calculate!(progress)

    save!
  end

  def confirm!(new_status)
    return unless new_status == PERSON_ESCORT_RECORD_CONFIRMED

    state_machine.confirm!
    save!
  rescue FiniteMachine::InvalidStateError
    errors.add(:status, "can't update to '#{new_status}' from '#{status}'")
    raise ActiveModel::ValidationError, self
  end

  def handle_event_run
    save if changed? && valid?
  end

private

  def sections_to_responded
    @sections_to_responded ||= FrameworkResponse.where(id: required_responses.map(&:id)).joins(:framework_question).select('DISTINCT responded, framework_questions.section')
  end

  def set_progress(responses)
    responded = responses.pluck(:responded)

    return PERSON_ESCORT_RECORD_COMPLETED if responded.all?(true)
    return PERSON_ESCORT_RECORD_NOT_STARTED if responded.all?(false)

    PERSON_ESCORT_RECORD_IN_PROGRESS
  end

  def required_responses
    framework_responses.includes(:framework_question, :parent).select do |framework_response|
      framework_response.parent ? framework_response.parent.option_selected?(framework_response.framework_question.dependent_value) : framework_response
    end
  end

  def previous_per
    @previous_per ||= profile&.person&.latest_person_escort_record
  end

  def previous_responses
    @previous_responses ||= begin
      return {} unless previous_per

      previous_per.framework_responses.includes(framework_question: :dependents).each_with_object({}) do |response, hash|
        value = response.prefill_value
        next if value.blank?

        hash[response.framework_question.key] = value
      end
    end
  end
end
