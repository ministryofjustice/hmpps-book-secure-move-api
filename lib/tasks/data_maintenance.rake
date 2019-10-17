# frozen_string_literal: true

namespace :data_maintenance do
  desc 'remove duplicated moves'
  task remove_duplicated_moves: :environment do
    duplicates = Move.select(:nomis_event_id).group(:nomis_event_id).having('COUNT(*) > 1').size
    duplicates.each_pair do |k, _|
      next if k.nil?

      moves = Move.order(:created_at).where(nomis_event_id: k).offset(1)
      moves.destroy_all
    end
  end
end
