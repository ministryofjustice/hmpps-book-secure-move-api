# frozen_string_literal: true

namespace :moves do
  desc 'Update the suppliers for all the moves based on the effective dates of the Suppliers'
  task update_suppliers: :environment do
    total = Move.count

    i = 0

    puts 'Updating suppliers for moves...'
    Move.find_each(batch_size: 200) do |move|
      # TODO: need to update this whith the new SupplierChooser
      new_supplier = SupplierChooser.new(nil, nil).call
      move.update(supplier: new_supplier)

      if (total % 200).zero?
        puts "Updated #{i += 200} out of #{total} moves..."
      end
    end

    puts 'Task completed.'
  end
end
