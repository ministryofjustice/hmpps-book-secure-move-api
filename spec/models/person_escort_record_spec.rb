# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  let(:from_location) { create(:location, :prison) }
  let(:alert) do
    {
      alert_id: 2,
      alert_code: 'VI',
      alert_code_description: 'Hold separately',
      comment: 'Some comment',
      created_at: '2013-03-29',
      expires_at: '2100-06-08',
      expired: false,
      active: true,
      prison_number: 'A9127EK',
    }
  end

  it { is_expected.to belong_to(:move).optional }
  it { is_expected.to have_many(:medical_events) }

  it 'creates NOMIS mappings for framework responses' do
    move = create(:move, from_location:)
    framework = create(:framework)
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    create(:framework_question, framework:, framework_nomis_codes: [alert_code])
    allow(AlertsApiClient::Alerts).to receive(:get).and_return([alert])
    person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

    expect(person_escort_record.framework_responses.first.framework_nomis_mappings.count).to eq(1)
  end

  it 'updates nomis sync status if successful' do
    move = create(:move, from_location:)
    framework = create(:framework)
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    create(:framework_question, framework:, framework_nomis_codes: [alert_code])
    allow(AlertsApiClient::Alerts).to receive(:get).and_return([alert])
    person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

    expect(person_escort_record.nomis_sync_status).to include_json(
      [
        { 'resource_type' => 'alerts', 'status' => 'success' },
      ],
    )
  end

  # To support legacy PERs without a move
  context 'when no move associated' do
    describe '#editable?' do
      it 'is editable if a PER is not confirmed' do
        person_escort_record = create(:person_escort_record, :with_responses, :without_move)

        expect(person_escort_record).to be_editable
      end

      it 'is not editable if a PER is confirmed' do
        person_escort_record = create(:person_escort_record, :confirmed, :with_responses, :without_move)

        expect(person_escort_record).not_to be_editable
      end
    end

    describe '#import_nomis_mappings!' do
      it 'does nothing if no move associated to person escort record' do
        framework = create(:framework)
        profile = create(:profile)
        alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
        question = create(:framework_question, framework:, framework_nomis_codes: [alert_code])
        response = create(:string_response, framework_question: question)
        person_escort_record = create(:person_escort_record, framework:, profile:, framework_responses: [response])

        expect { person_escort_record.import_nomis_mappings! }.not_to change(FrameworkNomisMapping, :count)
      end
    end
  end

  describe '#import_nomis_mappings!' do
    before do
      allow(AlertsApiClient::Alerts).to receive(:get).and_return([alert])
    end

    it 'imports nomis mappings if move is a prison' do
      framework = create(:framework)
      move = create(:move, from_location:)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework:, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      person_escort_record = create(:person_escort_record, framework:, move:, framework_responses: [response])

      expect { person_escort_record.import_nomis_mappings! }.to change(FrameworkNomisMapping, :count).by(1)
    end
  end

  describe '#confirm!' do
    it 'stores handover_details if provided' do
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', { foo: 'bar' })

      expect(assessment.handover_details).to eq({ 'foo' => 'bar' })
    end

    it 'stores handover_details on an already-confirmed PER if provided' do
      assessment = create(:person_escort_record, :confirmed)
      assessment.confirm!('confirmed', { foo: 'bar' })

      expect(assessment.handover_details).to eq({ 'foo' => 'bar' })
    end

    it 'throws an error if attempting to re-confirm an already confirmed PER without handover details' do
      assessment = create(:person_escort_record, :confirmed)
      expect { assessment.confirm!('confirmed', nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not store handover_details if blank' do
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', {})

      expect(assessment.handover_details).to be_empty
    end

    it 'does not store handover_details if nil' do
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', nil)

      expect(assessment.handover_details).to be_empty
    end

    it 'stores handover_occurred_at if provided' do
      timestamp = Time.zone.now
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', nil, timestamp.iso8601)

      expect(assessment.handover_occurred_at).to be_within(1.second).of timestamp
    end

    it 'does not store handover_occurred_at if blank' do
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', nil, '')

      expect(assessment.handover_occurred_at).to be_nil
    end

    it 'does not store handover_occurred_at if nil' do
      assessment = create(:person_escort_record, :completed)
      assessment.confirm!('confirmed', nil, nil)

      expect(assessment.handover_occurred_at).to be_nil
    end
  end

  it_behaves_like 'a framework assessment', :person_escort_record, described_class

  describe '#medical_events' do
    subject(:medical_events) { per.medical_events }

    let(:per) { create(:person_escort_record) }

    before { create(:event_per_medical_aid, eventable: per) }

    it { is_expected.not_to be_empty }
    it { is_expected.to include(GenericEvent::PerMedicalAid.first) }
  end

  describe '#incident_events' do
    subject(:incident_events) { per.incident_events }

    let(:per) { create(:person_escort_record) }

    before { create(:event_per_escape, eventable: per) }

    it { is_expected.not_to be_empty }
    it { is_expected.to include(GenericEvent::PerEscape.first) }
  end

  describe '#responded_by' do
    subject(:responded_by) { per.responded_by }

    let(:framework) { create(:framework) }
    let(:alert_code) { create(:framework_nomis_code, code: 'VI', code_type: 'alert') }
    let(:question) { create(:framework_question, framework:, framework_nomis_codes: [alert_code]) }
    let(:response1) { create(:string_response, section: 'section1', framework_question: question, responded_by: 'TEST_USER') }
    let(:response2) { create(:string_response, section: 'section1', framework_question: question, responded_by: 'TEST_USER') }
    let(:response3) { create(:string_response, section: 'section1', framework_question: question, responded_by: 'OTHER_TEST_USER') }
    let(:response4) { create(:string_response, section: 'section2', framework_question: question, responded_by: 'OTHER_TEST_USER') }
    let(:per) { create(:person_escort_record, framework_responses: [response1, response2, response3, response4]) }

    it 'returns the correct users for the correct sections' do
      expect(responded_by['section1']).to match_array(%w[TEST_USER OTHER_TEST_USER])
      expect(responded_by['section2']).to match_array(%w[OTHER_TEST_USER])
    end
  end
end
