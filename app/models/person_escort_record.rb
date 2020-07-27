class PersonEscortRecord < VersionedModel
  include StateMachineable

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

  has_many :framework_responses, dependent: :destroy

  belongs_to :framework
  has_many :framework_questions, through: :framework
  has_many :flags, through: :framework_responses
  belongs_to :profile

  has_state_machine PersonEscortRecordStateMachine, on: :status

  delegate :calculate,
           :confirm,
           :unstarted?,
           :in_progress?,
           :completed?,
           :confirmed?,
           to: :state_machine

  def self.save_with_responses!(profile_id:, version: nil)
    profile = Profile.find(profile_id)
    # TODO: remove default framework, getting the last framework is temporary until versioning is finalised
    framework = version.present? ? Framework.find_by!(version: version) : Framework.ordered_by_latest_version.first

    record = new(profile: profile, framework: framework)
    record.build_responses!
  end

  def build_responses!
    ActiveRecord::Base.transaction do
      save!

      questions = framework_questions.includes(:dependents).index_by(&:id)
      questions.values.each do |question|
        next unless question.parent_id.nil?

        response = question.build_responses(person_escort_record: self, questions: questions)
        framework_responses.build(response.slice(:type, :framework_question_id, :dependents))
      end

      PersonEscortRecord.import([self], validate: false, recursive: true, all_or_none: true, validate_uniqueness: true, on_duplicate_key_update: { conflict_target: [:id] })
    end

    self
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
end
