# frozen_string_literal: true

namespace :data_maintenance do
  desc 'remove duplicated moves'
  task remove_duplicate_moves: :environment do
    duplicates = Move.select(:nomis_event_ids).group(:nomis_event_ids).having('COUNT(*) > 1').size
    duplicates.each_pair do |k, _|
      next if k.nil?

      moves = Move.order(:created_at).where(nomis_event_ids: k).offset(1)
      moves.destroy_all
    end
  end

  desc 'move old nomis_event_id to nomis_event_ids'
  task move_event_id_to_event_ids: :environment do
    Move.where.not(nomis_event_id: nil).each do |move|
      move.update_attribute(:nomis_event_ids, [move.nomis_event_id])
    end
  end
end
