require 'rails_helper'

RSpec.describe GenericEvent::PerMedicalAid do
  subject(:generic_event) { build(:event_per_medical_aid) }

  it_behaves_like 'an event with details', :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :vehicle_reg
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_presence_of(:advised_at) }
  it { is_expected.to validate_presence_of(:advised_by) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  context 'when the advised_at date time format is not an iso8601 date' do
    before do
      generic_event.advised_at = advised_at
    end

    let(:advised_at) { '2019/01/01T18:00:00' }

    it { is_expected.not_to be_valid }
  end

  context 'when the treated_at date time format is not an iso8601 date' do
    before do
      generic_event.treated_at = treated_at
    end

    let(:treated_at) { '2019/01/01T18:00:00' }

    it { is_expected.not_to be_valid }
  end

  context 'when the treated_at and treated_by are nil' do
    before do
      generic_event.treated_by = nil
      generic_event.treated_at = nil
    end

    it { is_expected.to be_valid }
  end

  describe '#event_classification' do
    it 'returns :medical' do
      event = described_class.new

      expect(event.event_classification).to eq :medical
    end

    it 'is automatically assigned on creation' do
      event = create(:event_per_medical_aid, classification: nil)

      expect(event.classification).to eq 'medical'
    end
  end
end
