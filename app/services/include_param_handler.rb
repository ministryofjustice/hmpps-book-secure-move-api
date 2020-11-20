class IncludeParamHandler
  SEPARATOR = ','.freeze

  def initialize(params)
    @params = params
  end

  def included_relationships
    @included_relationships ||= @params[:include]&.split(SEPARATOR)
  end

  def active_record_relationships
    @active_record_relationships ||= included_relationships.map { |value| to_active_record_include_hash(value) } if included_relationships.present?
  end

private

  def to_active_record_include_hash(value)
    parts = value.split('.', 2)
    db_name = db_alias(parts.first)

    if parts.length == 1
      db_name
    else
      { db_name => to_active_record_include_hash(parts.last) }
    end
  end

  def db_alias(name)
    # NB: some relationships have a different name in the JSON API data compared with the underlying table
    case name
    when 'flags'
      :framework_flags
    when 'questions'
      :framework_questions
    when 'responses'
      :framework_responses
    when 'timeline_events'
      :events
    else
      name.to_sym
    end
  end
end
