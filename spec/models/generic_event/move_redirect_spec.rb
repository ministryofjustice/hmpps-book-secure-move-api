require 'rails_helper'

RSpec.describe GenericEvent::MoveRedirect do
  subject(:generic_event) { build(:event_move_redirect) } # this is a court_appearance redirect to a court

  let(:redirect_reasons) do
    %w[
      no_space
      serious_incident
      covid
      receiving_prison_request
      force_majeure
      other
    ]
  end

  it_behaves_like 'an event with details', :move_type, :reason
  it_behaves_like 'an event with relationships', to_location_id: :locations
  it_behaves_like 'a move event'
  it_behaves_like 'an event requiring a location', :to_location_id
  it_behaves_like 'an event with a location in the feed', :to_location_id

  it { is_expected.to validate_inclusion_of(:reason).in_array(redirect_reasons) }

  context 'when reason is nil' do
    before do
      generic_event.details.delete('reason')
    end

    it { is_expected.to be_valid }
  end

  describe '#to_location' do
    it 'returns a `Location` if to_location_id is in the details' do
      location = create(:location)
      generic_event.details['to_location_id'] = location.id
      expect(generic_event.to_location).to eq(location)
    end

    it 'returns nil if to_location_id is nil in the details' do
      generic_event.details['to_location_id'] = nil
      expect(generic_event.to_location).to be_nil
    end
  end

  describe '#move_type' do
    context 'when valid' do
      before do
        generic_event.details[:move_type] = 'court_appearance'
      end

      it { is_expected.to be_valid }
    end

    context 'when invalid with respect to the to_location' do
      before do
        generic_event.details[:move_type] = 'hospital'
      end

      it { is_expected.not_to be_valid }
    end

    context 'when unknown' do
      before do
        generic_event.details[:move_type] = 'FOO_BAR'
      end

      it { is_expected.not_to be_valid }
    end

    context 'when blank' do
      before do
        generic_event.details[:move_type] = ''
      end

      it { is_expected.to be_valid }
    end

    context 'when nil' do
      before do
        generic_event.details[:move_type] = nil
      end

      it { is_expected.to be_valid }
    end

    context 'when not present' do
      before do
        generic_event.details.delete(:move_type)
      end

      it { is_expected.to be_valid }
    end
  end

  describe '#trigger' do
    subject(:generic_event) { build(:event_move_redirect, details:, eventable:) }

    let(:details) { { move_type: 'court_appearance' } }

    let(:to_location) { create(:location) }
    let(:eventable) { build(:move, move_type: 'prison_transfer') }

    it 'does not persist changes to the eventable' do
      generic_event.trigger

      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `to_location` to the to_location' do
      expect { generic_event.trigger }.to change { generic_event.eventable.to_location }.to(generic_event.to_location)
    end

    context 'when a move_type is included in the details' do
      let(:details) do
        {
          move_type: 'court_appearance',
          to_location_id: to_location.id,
        }
      end

      it 'sets the eventable `move_type' do
        expect { generic_event.trigger }.to change { generic_event.eventable.move_type }.from('prison_transfer').to('court_appearance')
      end
    end

    context 'when it becomes a cross-deck move' do
      subject(:generic_event) { build(:event_move_redirect, details:, eventable:) }

      let(:departing_supplier) { create(:supplier) }
      let(:receiving_supplier) { create(:supplier) }
      let(:from_location) { create(:location, :court, suppliers: [departing_supplier]) }
      let(:old_to_location) { create(:location, :court, suppliers: [departing_supplier]) }
      let(:new_to_location) { create(:location, :court, suppliers: [receiving_supplier]) }
      let(:eventable) { build(:move, move_type: 'court_appearance', from_location:, to_location: old_to_location) }
      let(:details) { { reason: 'other', to_location_id: new_to_location.id } }

      before { allow(Notifier).to receive(:prepare_notifications) }

      it 'sends a cross_supplier_move_add notification to the receiving supplier' do
        generic_event.trigger
        expect(Notifier).to have_received(:prepare_notifications).with(topic: eventable, action_name: 'cross_supplier_add')
      end
    end

    context 'when it ceases to be a cross-deck move' do
      subject(:generic_event) { build(:event_move_redirect, details:, eventable:) }

      let(:departing_supplier) { create(:supplier) }
      let(:receiving_supplier) { create(:supplier) }
      let(:from_location) { create(:location, :court, suppliers: [departing_supplier]) }
      let(:old_to_location) { create(:location, :court, suppliers: [receiving_supplier]) }
      let(:new_to_location) { create(:location, :court, suppliers: [departing_supplier]) }
      let(:eventable) { build(:move, move_type: 'court_appearance', from_location:, to_location: old_to_location) }
      let(:details) { { reason: 'other', to_location_id: new_to_location.id } }

      before { allow(Notifier).to receive(:prepare_notifications) }

      it 'sends a cross_supplier_move_remove notification to the receiving supplier' do
        generic_event.trigger
        expect(Notifier).to have_received(:prepare_notifications).with(topic: eventable, action_name: 'cross_supplier_remove')
      end
    end
  end
end
