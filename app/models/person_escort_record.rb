class PersonEscortRecord < VersionedModel
  enum states: {
    in_progress: 'in_progress',
    completed: 'completed',
    confirmed: 'confirmed',
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
    record = new(profile: profile, framework: framework, state: 'in_progress')
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
end
