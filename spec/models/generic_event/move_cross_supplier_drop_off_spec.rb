RSpec.describe GenericEvent::MoveCrossSupplierDropOff do
  subject(:generic_event) { build(:event_move_cross_supplier_drop_off) }

  it_behaves_like 'a move event'
  it_behaves_like 'an event with eventable types', 'Move'
end
