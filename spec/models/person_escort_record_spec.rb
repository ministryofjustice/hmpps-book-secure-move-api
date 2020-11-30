# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  it { is_expected.to belong_to(:move).optional }

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

  it_behaves_like 'a framework assessment', :person_escort_record, described_class
end
