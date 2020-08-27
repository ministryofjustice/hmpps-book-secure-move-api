# frozen_string_literal: true

namespace :moves do
  desc 'Update the suppliers for all the moves based on the effective dates of the Suppliers'
  task update_suppliers: :environment do
    total = Move.count

    puts 'Updating suppliers for moves...'
    Move.find_each(batch_size: 200).with_index do |move, i|
      effective_date = move.date.presence || move.date_from
      supplier = SupplierChooser.new(effective_date, move.from_location).call

      if supplier.nil?
        puts_error(move)
      else
        move.supplier = supplier
        move.save(validate: false)
      end

      if (i % 200).zero?
        puts "Processed #{i} / #{total} moves..."
      end
    end

    puts 'Task completed.'
    puts 'To confirm you want to save the move, please specify the VAR "ENV[confirm]=true""' unless ENV['confirm_save'] == 'true'
  end
end

private

def puts_error(move)
  supplier_location = SupplierLocation.location(move.from_location.id) if move.from_location

  puts "ERROR: #{move.id} has supplier = nil!"
  puts "  Debug info: move.date: move.date:#{move.date}, move.date_from: #{move.date_from}, " \
    "move.from_location: #{move.from_location.inspect}, supplier_location: #{supplier_location.inspect}"
end
