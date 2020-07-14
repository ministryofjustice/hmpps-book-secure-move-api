# TODO: Remove this once we've added all suppliers to the all moves in all environments
namespace :move do
  desc 'Populates a move with a supplier'
  task supplier: :environment do
    total = Move.count
    total_updated = 0

    locations_with_supplier = Location.joins(:suppliers)

    moves_having_supplier = Move.where.not(supplier_id: nil).count
    moves_missing_supplier = Move.where.not(from_location: locations_with_supplier).where(supplier_id: nil).count

    locations_with_supplier.each do |from_location|
      supplier = from_location.suppliers.first

      Move.where(from_location: from_location).where(supplier_id: nil).in_batches(of: 200) do |batch|
        puts "Populating supplier #{supplier.name} for moves from #{from_location.title}"

        total_updated += batch.update_all(supplier_id: supplier.id)
        puts "#{total_updated}/#{total} moves populated..."
        puts
      end
    end

    puts "#{total} moves exist."
    puts "#{total_updated} moves have had their supplier updated."
    puts "#{moves_having_supplier} moves already have a supplier."
    puts "#{moves_missing_supplier} moves could not be updated as their from_location does not have a supplier"
  end
end
