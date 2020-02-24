namespace :move_profile do
  desc 'backfill move profile ids'
  task backfill: :environment do
    Move.includes(person: :profiles).find_each.reject { |m| m.profile_id.present? }.each do |move|
      move.update!(profile_id: move.person.latest_profile.id)
    end
  end
end
