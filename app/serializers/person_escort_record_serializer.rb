class PersonEscortRecordSerializer < ActiveModel::Serializer
  belongs_to :profile, record_type: :profile
  belongs_to :framework, record_type: :framework
  has_many :framework_responses, serializer: FrameworkResponseSerializer, key: :responses
  has_many :flags

  attributes :version, :status, :confirmed_at

  meta do
    { section_progress: object.section_progress }
  end

  def version
    object.framework.version
  end

  def framework_responses
    object.framework_responses.includes(:flags, framework_question: :framework)
  end

  def status
    if object.status == 'unstarted'
      'not_started'
    else
      object.status
    end
  end

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    profile.person
    responses.question
    flags
  ].freeze
end
