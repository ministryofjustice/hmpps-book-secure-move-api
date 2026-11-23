class SubjectAccessRequest
  # Timestamps are stored in UTC, but SAR date ranges are UK calendar days
  APP_TIME_ZONE = ActiveSupport::TimeZone[Rails.application.config.time_zone].tzinfo.identifier

  # Moves without a scheduled date fall back to date_from (proposed moves), then to the
  # UK date the move was created (e.g. cancelled moves, which may have neither)
  MOVE_DATE = Arel.sql(
    "COALESCE(moves.date, moves.date_from, (moves.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{APP_TIME_ZONE}')::date)",
  )

  attr_reader :prison_number, :from_date, :to_date

  def initialize(prison_number, from_date, to_date)
    @prison_number = prison_number
    @from_date = from_date
    @to_date = to_date
  end

  # Only people with data in the requested range are reported. If there are none, no
  # data is held for the range and the controller returns 204 rather than an empty report.
  def people
    @people ||= Person.where(prison_number:, created_at: before_to_date)
                      .order(:created_at)
                      .select { |person| data_in_range?(person) }
  end

  delegate :empty?, to: :people

  def fetch
    { content: people.map { |p| serialize_person(p) } }
  end

private

  # Exclusive upper bound so records created at any time on to_date are included. Dates are
  # converted to UK midnight, as plain dates would be compared against midnight UTC.
  def before_to_date
    @before_to_date ||= Date.new(1000).in_time_zone...(to_date + 1).in_time_zone
  end

  def in_range
    @in_range ||= from_date.in_time_zone...(to_date + 1).in_time_zone
  end

  def data_in_range?(person)
    moves_for(person).exists? || person.profiles.exists?(created_at: in_range)
  end

  def moves_for(person)
    person.moves
          .where("#{MOVE_DATE} BETWEEN ? AND ?", from_date, to_date)
          .order(MOVE_DATE, 'moves.created_at')
  end

  def serialize_person(person)
    relationships = {
      profiles: person.profiles.where(created_at: before_to_date).map { |p| serialize_profile(p) },
      moves: moves_for(person).map { |m| serialize_move(m) },
      events: person.generic_events.map { |e| serialize_event(e) },
    }

    relationships[:image] = ImageSerializer.new(person.image).serializable_hash if person.image.present?
    relationships[:ethnicity] = EthnicitySerializer.new(person.ethnicity).serializable_hash if person.ethnicity.present?
    relationships[:gender] = GenderSerializer.new(person.gender).serializable_hash if person.gender.present?

    PersonSerializer.new(person).serializable_hash.deep_merge(data: { relationships: })
  end

  def serialize_framework_response(framework_response)
    relationships = {
      question: FrameworkQuestionSerializer.new(framework_response.framework_question).serializable_hash,
      nomis_mappings: framework_response.framework_nomis_mappings.map { |m| FrameworkNomisMappingSerializer.new(m).serializable_hash },
      flags: framework_response.framework_flags.map { |f| FrameworkFlagSerializer.new(f).serializable_hash },
    }

    FrameworkResponseSerializer.new(framework_response).serializable_hash.deep_merge(data: { relationships: }).tap do |hash|
      # Empty object/array/string responses come through as {}, [] or "", which the report template
      # may not treat as empty. Send nil instead so the template shows "No Data Held".
      value = hash.dig(:data, :attributes, :value)
      hash[:data][:attributes][:value] = nil if value.respond_to?(:empty?) && value.empty?
    end
  end

  EXCLUDED_QUESTION_KEYS = %w[has-concealed-items concealed-items terrorism-offences hostage-taker escape-risk stalker-harasser-or-intimidator gang-member-or-organised-crime violent-or-dangerous].freeze

  def filtered_framework_responses(assessment)
    assessment.framework_responses.reject do |fr|
      EXCLUDED_QUESTION_KEYS.include?(fr.framework_question.key)
    end
  end

  def assessment_relationships(assessment)
    {
      events: assessment.generic_events.map { |e| serialize_event(e) },
      framework_responses: filtered_framework_responses(assessment)
                             .map { |fr| serialize_framework_response(fr) },
    }
  end

  def serialize_per(per)
    PersonEscortRecordSerializer.new(per).serializable_hash.deep_merge(data: { relationships: assessment_relationships(per) })
  end

  def serialize_yra(yra)
    YouthRiskAssessmentSerializer.new(yra).serializable_hash.deep_merge(data: { relationships: assessment_relationships(yra) })
  end

  def serialize_profile(profile)
    relationships = {
      documents: profile.documents.map { |d| DocumentSerializer.new(d).serializable_hash },
    }
    relationships[:person_escort_record] = serialize_per(profile.person_escort_record) if profile.person_escort_record.present?
    relationships[:youth_risk_assessment] = serialize_yra(profile.youth_risk_assessment) if profile.youth_risk_assessment.present?

    ProfileSerializer.new(profile).serializable_hash.deep_merge({ data: { relationships: } })
  end

  def serialize_journey(journey)
    relationships = {
      events: journey.generic_events.map { |e| serialize_event(e) },
    }
    relationships[:from_location] = serialize_location(journey.from_location) if journey.from_location.present?
    relationships[:to_location] = serialize_location(journey.to_location) if journey.to_location.present?

    JourneySerializer.new(journey).serializable_hash.deep_merge({ data: { relationships: } })
  end

  def serialize_event(event)
    GenericEventSerializer.new(event).serializable_hash
  end

  def serialize_location(location)
    LocationSerializer.new(location).serializable_hash.tap do |data|
      %i[disabled_at can_upload_documents extradition_capable].each do |k|
        data.dig(:data, :attributes).delete(k)
      end
    end
  end

  def serialize_ptr(ptr)
    PrisonTransferReasonSerializer.new(ptr).serializable_hash
  end

  def serialize_court_hearing(court_hearing)
    CourtHearingSerializer.new(court_hearing).serializable_hash
  end

  def serialize_move(move)
    relationships = {
      journeys: move.journeys.map { |j| serialize_journey(j) },
      events: move.generic_events.map { |e| serialize_event(e) },
      court_hearings: move.court_hearings.map { |ch| serialize_court_hearing(ch) },
    }
    relationships[:from_location] = serialize_location(move.from_location) if move.from_location.present?
    relationships[:to_location] = serialize_location(move.to_location) if move.to_location.present?
    relationships[:prison_transfer_reason] = serialize_ptr(move.prison_transfer_reason) if move.prison_transfer_reason.present?

    MoveSerializer.new(move).serializable_hash.deep_merge({ data: { attributes: { recall_date: move.recall_date }, relationships: } })
  end
end
