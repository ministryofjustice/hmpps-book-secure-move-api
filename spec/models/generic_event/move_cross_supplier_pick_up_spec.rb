RSpec.describe GenericEvent::MoveCrossSupplierPickUp do
  subject(:generic_event) { build(:event_move_cross_supplier_pick_up) }

  it_behaves_like 'an event with eventable types', 'Move'

  context 'when the previous_move_id is missing' do
    before do
      generic_event.previous_move_id = nil
    end

    it 'returns an ActiveRecord error' do
      expect { generic_event.save }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Move without an ID")
    end
  end
end
