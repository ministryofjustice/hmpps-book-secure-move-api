# frozen_string_literal: true

namespace :prisoner_category do
  desc 'migrates category_code to category model'
  task migrate_category_codes: :environment do
    # NB we need to update profiles without touching the updated_at field
    res = ActiveRecord::Base.connection.execute('UPDATE Profiles p1
          SET category_id = categories.id
          FROM Profiles p2
            LEFT JOIN Categories ON p2.category_code = categories.key
          WHERE p1.id = p2.id
            AND p2.category_code IS NOT NULL')

    puts "Updated #{res.cmd_tuples.to_s(:delimited)} profiles with category_id"
  end
end
