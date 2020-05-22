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

  desc 'cancel all NOMIS synched moves from prisons'
  task cancel_synched_prison_moves: :environment do
    Location.prisons.each do |prison|
      from_moves = prison.moves_from.requested.select(&:from_nomis?).each do |move|
        move.update!(
          status: Move::MOVE_STATUS_CANCELLED,
          cancellation_reason: Move::CANCELLATION_REASON_MADE_IN_ERROR,
        )
      end

      puts "Prison #{prison.title} cancelled #{from_moves.size} moves" if from_moves.any?
    end
  end

  desc 'move old nomis_event_id to nomis_event_ids'
  task move_event_id_to_event_ids: :environment do
    Move.where.not(nomis_event_id: nil).each do |move|
      move.update_attribute(:nomis_event_ids, [move.nomis_event_id])
    end
  end
end
