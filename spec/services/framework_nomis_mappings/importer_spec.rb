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
    question = create(:framework_question, framework_nomis_codes: [personal_care_need_code, reasonable_adjustment_fallback, personal_care_need_fallback])
    create(:string_response, framework_question: question)
  end

  let(:person) do
    create(:person, :nomis_synced, latest_nomis_booking_id: 111_111)
  end

  before do
    allow(NomisClient::Alerts).to receive(:get).and_return(nomis_alerts)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(nomis_personal_care_needs)
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return(nomis_reasonable_adjustments)
  end

  it 'persists all alerts, reasonable adjustments and personal care needs from NOMIS clients as NOMIS mappings' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(person_escort_record: person_escort_record).call }.to change(FrameworkNomisMapping, :count).by(6)
  end

  it 'associates NOMIS mappings correctly to framework responses' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'VI')
  end

  it 'associates duplicate NOMIS mapping codes and types to framework responses' do
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    question = create(:framework_question, framework_nomis_codes: [alert_code])
    framework_response2 = create(:string_response, framework_question: question)
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code, :code_type)).to contain_exactly(%w[VI alert], %w[VI alert])
    expect(framework_response2.framework_nomis_mappings.pluck(:code, :code_type)).to contain_exactly(%w[VI alert], %w[VI alert])
  end

  it 'associates multiple NOMIS mappings to a fallback question response' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(framework_response2.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'DA', 'PEEP', 'BA')
  end

  it 'associates NOMIS mapping codes to responses scoped to NOMIS mapping type' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code_type).uniq).to contain_exactly('alert')
    expect(framework_response2.framework_nomis_mappings.pluck(:code_type).uniq).to contain_exactly('reasonable_adjustment', 'personal_care_need')
  end

  it 'does not associate NOMIS mappings mapped to a fallback if none exist' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(framework_response1.framework_nomis_mappings.pluck(:code)).to contain_exactly('VI', 'VI')
  end

  it 'persists other NOMIS mappings if one import fails' do
    oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '', 'error=': '')
    allow(NomisClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(person_escort_record: person_escort_record).call }.to change(FrameworkNomisMapping, :count).by(4)
  end

  it 'does nothing if no NOMIS mappings present for a person' do
    allow(NomisClient::Alerts).to receive(:get).and_return([])
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return([])
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([])
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    expect { described_class.new(person_escort_record: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no person_escort_record present' do
    expect { described_class.new(person_escort_record: nil).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no framework responses present' do
    person_escort_record = create(:person_escort_record, framework_responses: [], profile: person.profiles.first)

    expect { described_class.new(person_escort_record: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'does nothing if no framework NOMIS codes present' do
    person_escort_record = create(:person_escort_record, framework_responses: [create(:string_response)], profile: person.profiles.first)

    expect { described_class.new(person_escort_record: person_escort_record).call }.not_to change(FrameworkNomisMapping, :count)
  end

  it 'persists the NOMIS status sync attribute on the person escort record' do
    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)

    described_class.new(person_escort_record: person_escort_record).call

    expect(person_escort_record.nomis_sync_status).to include_json(
      [
        { 'resource_type' => 'alerts', 'status' => 'success' },
        { 'resource_type' => 'personal_care_needs', 'status' => 'success' },
        { 'resource_type' => 'reasonable_adjustments', 'status' => 'success' },
      ],
    )
  end

  it 'sets different sync statuses per NOMIS client attribute on the person escort record' do
    oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '', 'error=': '')
    allow(NomisClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)

    person_escort_record = create(:person_escort_record, framework_responses: [framework_response1, framework_response2], profile: person.profiles.first)
    described_class.new(person_escort_record: person_escort_record).call

    expect(person_escort_record.nomis_sync_status).to include_json(
      [
        { 'resource_type' => 'alerts', 'status' => 'failed' },
        { 'resource_type' => 'personal_care_needs', 'status' => 'success' },
        { 'resource_type' => 'reasonable_adjustments', 'status' => 'success' },
      ],
    )
  end

  it 'does not set a status if no importing attempted' do
    person_escort_record = create(:person_escort_record, framework_responses: [create(:string_response)], profile: person.profiles.first)

    expect(person_escort_record.nomis_sync_status).to be_empty
  end
end
