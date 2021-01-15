class IncludeParamHandler
  SEPARATOR = ','.freeze

  def initialize(params)
    @params = params.permit(:include, :meta)
  end

  def included_relationships
    @params[:include]&.split(SEPARATOR)
  end

  def meta_fields
    @params[:meta]&.split(SEPARATOR)
  end

  def active_record_relationships
    @active_record_relationships ||= relationships_and_fields.map { |value| to_active_record_include_hash(value) } if relationships_and_fields.present?
  end

private

  def relationships_and_fields
    included_relationships.to_a + meta_fields.to_a
  end

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
    when 'question'
      :framework_question
    when 'descendants'
      :dependents
    when '**'
      # This was required for the old JSON serializer, which did not load nested resources.
      # This can be deprecated after clients move off it, and this nested include can move to
      # `descendants` instead.
      { dependents: :dependents }
    when 'nomis_mappings'
      :framework_nomis_mappings
    when 'responses'
      :framework_responses
    when 'timeline_events'
      :generic_events
    when 'important_events'
      { incident_events: {}, profile: { person_escort_record: :medical_events } }
    when 'expected_time_of_arrival', 'expected_collection_time'
      :notification_events
    when 'vehicle_registration'
      :journeys
    else
      name.to_sym
    end
  end
end
