class PersonEscortRecordSerializer < ActiveModel::Serializer
  belongs_to :profile, record_type: :profile
  belongs_to :framework, record_type: :framework
  has_many :framework_responses, serializer: FrameworkResponseSerializer, key: :responses

  attribute :version
  attribute :state, key: :status

  meta do
    { section_progress: object.section_progress }
  end

  def version
    object.framework.version
  end

  def framework_responses
    object.framework_responses.includes(framework_question: :framework)
  end

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    profile.person
    responses.question
  ].freeze
end
