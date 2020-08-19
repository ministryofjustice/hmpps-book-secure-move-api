# frozen_string_literal: true

namespace :data_maintenance do
  desc 'remove duplicated moves'
  task remove_duplicate_moves: :environment do
    duplicates = Move
                 .select(:from_location_id, :to_location_id, :person_id, :date)
                 .group(:from_location_id, :to_location_id, :person_id, :date)
                 .having('COUNT(*) > 1').size

    duplicates.each_pair do |k, _|
      next if k.nil? && !Location.find(k[0]).prison?

      moves = Move
              .order(:created_at)
              .where(from_location_id: k[0], to_location_id: k[1], person_id: k[2], date: k[3])
              .offset(1)
      moves.destroy_all
    end
  end

  desc 'fix incorrect move_agreed for all moves except prison transfers'
  task fix_move_agreed_for_non_prison_transfers: :environment do
    Move.where(move_agreed: false).where.not(move_type: 'prison_transfer').update_all(move_agreed: nil)
  end

  desc 'fix nil estate for all existing production allocations data'
  task fix_nil_allocations_estate: :environment do
    Allocation.where(estate: nil).update_all(estate: :adult_male)
  end
end
