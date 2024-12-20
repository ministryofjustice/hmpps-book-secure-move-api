# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::Importer do
  let(:nomis_alerts) do
    [
      {
        alert_id: 2,
        alert_code: 'VI',
        alert_code_description: 'Hold separately',
        comment: 'Some comment',
        created_at: '2013-03-29',
        expires_at: '2100-06-08',
        expired: false,
        active: true,
        offender_no: 'A9127EK',
      },
      {
        alert_id: 3,
        alert_code: 'VI',
        alert_code_description: 'Hold separately',
        comment: 'Some other comment',
        created_at: '2013-04-29',
        expires_at: '2101-07-09',
        expired: false,
        active: true,
        offender_no: 'A9127EK',
      },
    ]
  end

  let(:nomis_assessments) do
    [
      {
        assessment_code: 'CSR',
        assessment_description: 'Cell Share Risk Assessment',
        classification: 'Standard',
        approval_date: '2020-01-01',
        next_review_date: '2100-04-23',
        offender_no: '321',
      },
    ]
  end

  let(:nomis_contacts) do
    [
      {
        active_flag: true,
        next_of_kin: true,
        first_name: 'First',
        middle_name: 'Middle',
        last_name: 'Last',
      },
    ]
  end

  let(:nomis_reasonable_adjustments) do
    [
      {
        treatment_code: 'DA',
        comment_text: 'Some comment',
        start_date: '2014-03-29',
        end_date: nil,
        agency_id: 'LGI',
        treatment_description: 'Some treatment description about DA',
      },
      {
        treatment_code: 'BA',
        comment_text: 'Some comment',
        start_date: '2014-03-29',
        end_date: nil,
        agency_id: 'AGI',
        treatment_description: 'Some treatment description about BA',
      },
    ]
  end

  let(:nomis_personal_care_needs) do
    [
      {
        problem_code: 'VI',
        problem_status: 'ON',
        problem_description: 'Visually impaired',
        start_date: '2015-03-29',
        end_date: '2100-06-08',
        offender_no: '321',
      },
      {
        problem_code: 'PEEP',
        problem_status: 'ON',
        problem_description: 'Special vehicle',
        start_date: '2015-03-29',
        end_date: '2100-06-08',
        offender_no: '321',
      },
    ]
  end

  let(:framework_response1) do
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    question = create(:framework_question, framework_nomis_codes: [alert_code])
    create(:string_response, framework_question: question)
  end

  let(:framework_response2) do
    personal_care_need_code = create(:framework_nomis_code, code: 'VI', code_type: 'personal_care_need')
    reasonable_adjustment_fallback = create(:framework_nomis_code, code: nil, code_type: 'reasonable_adjustment', fallback: true)
    personal_care_need_fallback = create(:framework_nomis_code, code: nil, code_type: 'personal_care_need', fallback: true)
    assessment_code = create(:framework_nomis_code, code: 'CSR', code_type: 'assessment')
    contact_code = create(:framework_nomis_code, code: 'NEXTOFKIN', code_type: 'contact')
    question = create(:framework_question, framework_nomis_codes: [assessment_code, contact_code, personal_care_need_code, reasonable_adjustment_fallback, personal_care_need_fallback])
    create(:string_response, framework_question: question)
  end

  let(:person) do
    create(:person, :nomis_synced, latest_nomis_booking_id: 111_111)
  end

  before do
    allow(AlertsApiClient::Alerts).to receive(:get).and_return(nomis_alerts)
    allow(NomisClient::Assessments).to receive(:get).and_return(nomis_assessments)
    allow(NomisClient::Contacts).to receive(:get).and_return(nomis_contacts)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(nomis_personal_care_needs)
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return(nomis_reasonable_adjustments)
  end

  it 'persists all alerts, assessments, contacts, reasonable adjustments and personal care needs from NOMIS clients as NOMIS mappings' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(assessmentable: person_escort_record).call }.to change(FrameworkNomisMapping, :count).by(8)
  end

  it 'associates NOMIS mappings correctly to framework responses' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'VI')
  end

  it 'associates duplicate NOMIS mapping codes and types to framework responses' do
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    question = create(:framework_question, framework_nomis_codes: [alert_code])
    framework_response2 = create(:string_response, framework_question: question)
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code, :code_type)).to contain_exactly(%w[VI alert], %w[VI alert])
    expect(framework_response2.framework_nomis_mappings.pluck(:code, :code_type)).to contain_exactly(%w[VI alert], %w[VI alert])
  end

  it 'associates multiple NOMIS mappings to a fallback question response' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(framework_response2.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'DA', 'PEEP', 'BA', 'CSR', 'NEXTOFKIN')
  end

  it 'associates NOMIS mapping codes to responses scoped to NOMIS mapping type' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code_type).uniq).to contain_exactly('alert')
    expect(framework_response2.framework_nomis_mappings.pluck(:code_type).uniq).to contain_exactly('assessment', 'contact', 'reasonable_adjustment', 'personal_care_need')
  end

  it 'does not associate NOMIS mappings mapped to a fallback if none exist' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'VI')
  end

  it 'persists other NOMIS mappings if one import fails' do
    oauth2_response = instance_double(OAuth2::Response, body: '{}', parsed: {}, status: '')
    allow(AlertsApiClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(assessmentable: person_escort_record).call }.to change(FrameworkNomisMapping, :count).by(6)
  end

  it 'does nothing if no NOMIS mappings present for a person' do
    allow(AlertsApiClient::Alerts).to receive(:get).and_return([])
    allow(NomisClient::Assessments).to receive(:get).and_return([])
    allow(NomisClient::Contacts).to receive(:get).and_return([])
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return([])
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([])
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(assessmentable: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no person_escort_record present' do
    expect { described_class.new(assessmentable: nil).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no framework responses present' do
    person_escort_record = create(:person_escort_record, framework_responses: [], profile: person.profiles.first)

    expect { described_class.new(assessmentable: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no framework NOMIS codes present' do
    person_escort_record = create(:person_escort_record, framework_responses: [create(:string_response)], profile: person.profiles.first)

    expect { described_class.new(assessmentable: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'persists the NOMIS status sync attribute on the person escort record' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    described_class.new(assessmentable: person_escort_record).call

    expect(person_escort_record.nomis_sync_status).to include_json(
      [
        { 'resource_type' => 'alerts', 'status' => 'success' },
        { 'resource_type' => 'assessments', 'status' => 'success' },
        { 'resource_type' => 'contacts', 'status' => 'success' },
        { 'resource_type' => 'personal_care_needs', 'status' => 'success' },
        { 'resource_type' => 'reasonable_adjustments', 'status' => 'success' },
      ],
    )
  end

  it 'sets different sync statuses per NOMIS client attribute on the person escort record' do
    oauth2_response = instance_double(OAuth2::Response, body: '{}', parsed: {}, status: '')
    allow(AlertsApiClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)

    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(person_escort_record.nomis_sync_status).to include_json(
      [
        { 'resource_type' => 'alerts', 'status' => 'failed' },
        { 'resource_type' => 'assessments', 'status' => 'success' },
        { 'resource_type' => 'contacts', 'status' => 'success' },
        { 'resource_type' => 'personal_care_needs', 'status' => 'success' },
        { 'resource_type' => 'reasonable_adjustments', 'status' => 'success' },
      ],
    )
  end

  it 'does not set a status if no importing attempted' do
    person_escort_record = create(:person_escort_record, framework_responses: [create(:string_response)], profile: person.profiles.first)
    described_class.new(assessmentable: person_escort_record).call

    expect(person_escort_record.nomis_sync_status).to be_empty
  end

  context 'when logging errors' do
    subject { described_class.new(assessmentable: person_escort_record).call }

    let(:person_escort_record) do
      create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    end

    context 'when validation fails on persisting NOMIS mappings' do
      before do
        nomis_alert = { comment: 'Some comment', expired: false, active: true }
        allow(AlertsApiClient::Alerts).to receive(:get).and_return([nomis_alert])
      end

      include_examples 'captures a message in Sentry' do
        let(:sentry_message) { 'FrameworkNomisMapping import validation Error' }
        let(:sentry_options) do
          {
            extra: {
              assessmentable_id: person_escort_record.id,
              error_messages: [{ code: ["can't be blank"] }],
            },
            tags: {},
            level: :error,
          }
        end
      end
    end

    context 'when a NOMIS resource is new' do
      include_examples 'captures a message in Sentry' do
        let(:sentry_message) { 'New NOMIS codes imported' }
        let(:sentry_options) do
          {
            extra: { assessmentable_id: person_escort_record.id },
            tags: { nomis_code: 'PEEP', nomis_type: 'personal_care_need' },
            level: :warning,
          }
        end
      end
    end
  end

  context 'with transaction failure' do
    it 'raises an error if transaction fails twice' do
      person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

      allow(person_escort_record).to receive(:update!).and_raise(ActiveRecord::PreparedStatementCacheExpired).twice

      expect { described_class.new(assessmentable: person_escort_record).call }.to raise_error(ActiveRecord::PreparedStatementCacheExpired)
    end

    it 'retries the transaction if it fails only once and updates person_escort_record' do
      person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
      nomis_sync_status = [
        { 'resource_type' => 'alerts', 'status' => 'success' },
      ]

      # Allow update to fail first time, and second time to complete transaction
      return_values = [:raise, true]
      allow(person_escort_record).to receive(:update!).twice do
        return_value = return_values.shift
        return_value == :raise ? raise(ActiveRecord::PreparedStatementCacheExpired) : person_escort_record.update(nomis_sync_status:) # rubocop:disable Rails/SaveBang
      end

      described_class.new(assessmentable: person_escort_record).call

      expect(person_escort_record.nomis_sync_status).to eq(nomis_sync_status)
    end
  end
end
