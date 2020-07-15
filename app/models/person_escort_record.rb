class PersonEscortRecord < VersionedModel
  PERSON_ESCORT_RECORD_NOT_STARTED = 'not_started'.freeze
  PERSON_ESCORT_RECORD_IN_PROGRESS = 'in_progress'.freeze
  PERSON_ESCORT_RECORD_COMPLETED = 'completed'.freeze
  PERSON_ESCORT_RECORD_CONFIRMED = 'confirmed'.freeze

  enum states: {
    in_progress: PERSON_ESCORT_RECORD_IN_PROGRESS,
    completed: PERSON_ESCORT_RECORD_COMPLETED,
    confirmed: PERSON_ESCORT_RECORD_CONFIRMED,
  }

  validates :state, presence: true, inclusion: { in: states }
  has_many :framework_responses, dependent: :destroy

  belongs_to :framework
  has_many :framework_questions, through: :framework
  belongs_to :profile
  validates :profile, uniqueness: true

  def self.save_with_responses!(profile_id:, version: nil)
    profile = Profile.find(profile_id)
    # TODO: remove default framework, getting the last framework is temporary until versioning is finalised
    framework = version.present? ? Framework.find_by!(version: version) : Framework.ordered_by_latest_version.first

    # TODO: add state machine
    record = new(profile: profile, framework: framework, state: PERSON_ESCORT_RECORD_IN_PROGRESS)
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
    sections_to_responded.each do |section, responses|
      sections_to_responded[section] = set_progress(responses)
    end
  end

private

  def sections_to_responded
    @sections_to_responded ||= framework_responses.joins(:framework_question).select('DISTINCT responded, framework_questions.section').group_by(&:section)
  end

  def set_progress(responses)
    responded = responses.pluck(:responded).uniq
    if responded.include?(true)
      responded.include?(false) ? PERSON_ESCORT_RECORD_IN_PROGRESS : PERSON_ESCORT_RECORD_COMPLETED
    else
      PERSON_ESCORT_RECORD_NOT_STARTED
    end
  end
end
