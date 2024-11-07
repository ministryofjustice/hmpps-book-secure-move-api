RSpec.shared_examples 'an event about a medical' do
  it_behaves_like 'an event with details', :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :police_personnel_number, :vehicle_reg
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it { is_expected.to validate_presence_of(:supplier_personnel_number) }

  context 'when the advised_at date time format is not an iso8601 date' do
    before { generic_event.advised_at = advised_at }

    let(:advised_at) { '2019/01/01T18:00:00' }

    it { is_expected.not_to be_valid }
  end

  context 'when the treated_at date time format is not an iso8601 date' do
    before { generic_event.treated_at = treated_at }

    let(:treated_at) { '2019/01/01T18:00:00' }

    it { is_expected.not_to be_valid }
  end

  context 'when the advised_at, advised_by, treated_at and treated_by are nil' do
    before do
      generic_event.advised_at = nil
      generic_event.advised_by = nil
      generic_event.treated_at = nil
      generic_event.treated_by = nil
    end

    it { is_expected.to be_valid }
  end

  describe '#event_classification' do
    subject(:event_classification) { generic_event.event_classification }

    it { is_expected.to eq(:medical) }
  end
end
