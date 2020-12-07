# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  let(:from_location) { create(:location, :prison) }
  let(:nomis_alert) do
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
    }
  end

  it { is_expected.to belong_to(:move).optional }

  it 'creates NOMIS mappings for framework responses' do
    move = create(:move, from_location: from_location)
    framework = create(:framework)
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    person_escort_record = described_class.save_with_responses!(move_id: move.id, version: framework.version)

    expect(person_escort_record.framework_responses.first.framework_nomis_mappings.count).to eq(1)
  end

  it 'updates nomis sync status if successful' do
    move = create(:move, from_location: from_location)
    framework = create(:framework)
    alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
    create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
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
        person_escort_record = create(:person_escort_record, :with_responses, move: nil)

        expect(person_escort_record).to be_editable
      end

      it 'is not editable if a PER is confirmed' do
        person_escort_record = create(:person_escort_record, :confirmed, :with_responses, move: nil)

        expect(person_escort_record).not_to be_editable
      end
    end

    describe '#import_nomis_mappings!' do
      it 'does nothing if no move associated to person escort record' do
        framework = create(:framework)
        profile = create(:profile)
        alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
        question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
        response = create(:string_response, framework_question: question)
        person_escort_record = create(:person_escort_record, framework: framework, profile: profile, framework_responses: [response])

        expect { person_escort_record.import_nomis_mappings! }.not_to change(FrameworkNomisMapping, :count)
      end
    end
  end

  describe '#import_nomis_mappings!' do
    before do
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    end

    it 'imports nomis mappings if move is a prison' do
      framework = create(:framework)
      move = create(:move, from_location: from_location)
      alert_code = create(:framework_nomis_code, code: 'VI', code_type: 'alert')
      question = create(:framework_question, framework: framework, framework_nomis_codes: [alert_code])
      response = create(:string_response, framework_question: question)
      person_escort_record = create(:person_escort_record, framework: framework, move: move, framework_responses: [response])

      expect { person_escort_record.import_nomis_mappings! }.to change(FrameworkNomisMapping, :count).by(1)
    end
  end

  it_behaves_like 'a framework assessment', :person_escort_record, described_class
end
