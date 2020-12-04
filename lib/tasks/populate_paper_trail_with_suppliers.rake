# frozen_string_literal: true

namespace :paper_trail do
  desc 'Populate PaperTrail::Versions with Supplier ids found in the whodunnit field'
  task :populate_with_suppliers, %i[up_down] => :environment do |_, args|
    if args[:up_down] == 'up' || args[:up_down].blank?
      res = ActiveRecord::Base.connection.execute('UPDATE versions SET supplier_id = whodunnit::uuid, whodunnit = null
                                                   WHERE whodunnit IN (SELECT id::text FROM suppliers)')

      puts "Populated #{res.cmd_tuples.to_s(:delimited)} PaperTrail::Versions with Supplier ids from whodunnit."
    elsif args[:up_down] == 'down'
      res = ActiveRecord::Base.connection.execute('UPDATE versions SET whodunnit = supplier_id, supplier_id = null WHERE
                                                   supplier_id IS NOT NULL')

      puts "Reverted #{res.cmd_tuples.to_s(:delimited)} PaperTrail::Versions, replacing whodunnit with Supplier id."
    else
      abort("Invalid argument: '#{args[:up_down]}', must be either 'up' or 'down'.")
    end
  end
end
