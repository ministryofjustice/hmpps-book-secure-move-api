namespace :access_logs do
  desc 'Cleanup access_logs older than 1 year'
  task cleanup: [:environment] do
    cutoff_date = 1.year.ago
    access_logs_count = AccessLog.where('timestamp < ?', cutoff_date).count
    number_of_iterations = (access_logs_count.to_f / 1000).ceil

    puts "Cleaning up #{access_logs_count} access_logs in #{number_of_iterations} iterations"

    1.upto(number_of_iterations).each do
      AccessLog.where('timestamp < ?', cutoff_date).limit(1000).delete_all
    end
  end
end
