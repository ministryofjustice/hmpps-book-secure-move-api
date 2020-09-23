class AddSupplierToGenericEvents < ActiveRecord::Migration[6.0]
  def change
    # Adds reference to supplier in generic event so that we can track the supplier via the existing
    # and new event api through doorkeeper tokens
    add_reference :generic_events, :supplier, type: :uuid, foreign_key: true, index: true
  end
end
