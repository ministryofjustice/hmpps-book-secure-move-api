namespace :allocations do
  desc 'Refresh allocation moves count and status'
  task refresh_data: :environment do
    Allocation.find_each(&:refresh_status_and_moves_count!)
  end
end
