require 'rails_helper'

RSpec.describe GenericEvent::MoveCrossSupplierPickUp do
  subject(:generic_event) { build(:event_move_cross_supplier_pick_up) }

  context 'with move id' do
    before { generic_event.validate }

    describe 'previous_move_reference' do
      it 'matches previous_move.reference' do
        expect(generic_event.previous_move_reference).to eql(generic_event.previous_move.reference)
        expect(generic_event.previous_move_reference).to be_present
      end
    end
  end

  context 'with move reference' do
    subject(:generic_event) { build(:event_move_cross_supplier_pick_up, :with_move_reference) }

    before { generic_event.validate }

    describe 'previous_move_reference' do
      it 'matches previous_move.reference' do
        expect(generic_event.previous_move_reference).to eql(generic_event.previous_move.reference)
        expect(generic_event.previous_move_reference).to be_present
      end
    end
  end

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
