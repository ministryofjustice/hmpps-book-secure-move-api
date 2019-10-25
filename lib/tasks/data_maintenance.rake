# frozen_string_literal: true

namespace :data_maintenance do
  desc 'move old nomis_event_id to nomis_event_ids'
  task move_event_id_to_event_ids: :environment do
    Move.where.not(nomis_event_id: nil).each do |move|
      move.update_attribute(:nomis_event_ids, [move.nomis_event_id])
    end
  end
end
