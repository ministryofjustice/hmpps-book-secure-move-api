class ReplaceMoveOvernightLodgeWithLodgeCreate < ActiveRecord::Migration[7.0]
  def change
    GenericEvent.where(type: 'GenericEvent::MoveOvernightLodge').update_all(type: 'GenericEvent::LodgingCreate')
  end
end
