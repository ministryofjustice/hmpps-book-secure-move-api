namespace :notifications do
  desc 'Send webhook and email notifications to the specified supplier for future moves'
  task :send, %i[supplier from_date send_webhooks send_emails] => :environment do |_, args|
    abort "Please specify a supplier, e.g. $ rake 'notifications:test_webhook[serco]'" if args[:supplier].blank?
    supplier = Supplier.find_by(key: args[:supplier]) || Supplier.find_by(id: args[:supplier]) || Supplier.find_by(name: args[:supplier])
    abort "Unknown supplier: #{args[:supplier]}" if supplier.blank?

    from_date = args[:from_date].present? ? Date.parse(args[:from_date]) : Time.zone.today
    send_webhooks = args[:send_webhooks].present? ? args[:send_webhooks] == 'true' : true # default to sending webhooks
    send_emails = args[:send_emails].present? ? args[:send_emails] == 'true' : false # default to not sending emails

    statuses = [Move::MOVE_STATUS_REQUESTED, Move::MOVE_STATUS_BOOKED]

    # moves directly assigned to the supplier
    moves_assigned = Move
      .where(supplier: supplier)
      .where('date >= ?', from_date)
      .where(status: statuses)

    # moves that don't belong to any supplier
    moves_unassigned = Move
      .where(supplier_id: nil)

    puts "For moves dated from #{from_date} with statuses of #{statuses}"
    puts "\tthere are #{moves_assigned.count} assigned moves for #{supplier.name}"
    puts "\tthere are #{moves_unassigned.count} moves not assigned to any supplier"

    puts "Sending webhooks: #{send_webhooks}"
    puts "Sending emails: #{send_emails}"

    puts "\nAre you sure you want to trigger these notifications? Enter YES to confirm:"
    print '> '
    confirm = STDIN.gets.chomp

    abort 'Cancelling' unless confirm =~ /Y(ES)?/i

    puts 'Processing assigned moves...'
    moves_assigned.find_each do |move|
      PrepareMoveNotificationsJob.perform_now(topic_id: move.id, action_name: 'update', send_webhooks: send_webhooks, send_emails: send_emails, only_supplier_id: supplier.id)
    end

    puts 'All done.'
  end
end
