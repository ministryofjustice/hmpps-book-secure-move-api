class SubjectAccessRequest
  attr_reader :prison_number, :from_date, :to_date

  def initialize(prison_number, from_date, to_date)
    @prison_number = prison_number
    @from_date = from_date
    @to_date = to_date
  end

  def people
    @people ||= Person.where(prison_number:, created_at: before_to_date)
  end

  delegate :empty?, to: :people

  def fetch
    { content: people.map { |p| serialize_person(p) } }
  end

private

  def before_to_date
    @before_to_date ||= Date.new(1000)..to_date
  end

  def date_range
    @date_range ||= from_date..to_date
  end

  def serialize_person(person)
    relationships = {
      profiles: person.profiles.where(created_at: before_to_date).map { |p| serialize_profile(p) },
      moves: person.moves.where(created_at: before_to_date).map { |m| serialize_move(m) },
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

    FrameworkResponseSerializer.new(framework_response).serializable_hash.deep_merge(data: { relationships: })
  end

  def assessment_relationships(assessment)
    {
      events: assessment.generic_events.map { |e| serialize_event(e) },
      framework_responses: assessment.framework_responses.map { |fr| serialize_framework_response(fr) },
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

    MoveSerializer.new(move).serializable_hash.deep_merge({ data: { relationships: } })
  end
end
