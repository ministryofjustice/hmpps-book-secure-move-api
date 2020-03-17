require 'open3'

namespace :test_data do
  MODELS = %w(Move Profile Person Supplier Location Ethnicity Gender Nationality PrisonTransferReason AssessmentQuestion NomisAlert).freeze

  desc 'clear down current database'
  task clear_local_tables: :environment do
    MODELS.each do |model|
      Module.const_get(model).destroy_all
    end
    PaperTrail::Version.delete_all
  end

  desc 'load from read-only env into our DB'
  task dump_load: :environment do
    db_name = if Rails.env.test?
                Rails.configuration.database_configuration[Rails.env]['database']
              else
                ENV['RO_DATABASE_URL']
              end
    # all models plus 1 join table between locations and suppliers, and the papertrail versions table
    tables = MODELS.map { |model| Module.const_get(model).table_name } + %w[locations_suppliers versions]
    pg_dump = ['pg_dump', '--column-inserts', '--data-only'] +
      tables.map { |table| "--table=#{table}" } + [db_name]
    Open3.popen2(*pg_dump) do |_dumpin, dump_out, dump_status|
      # to allow testing with test db and fake_data:recreate_all
      if Rails.env.test?
        dump_out.each_line do |line|
          puts line
        end
      else
        ingest_args = ['rails', 'db', '-p']
        Open3.popen2(*ingest_args) do |injest_in, _injest_out, injest_status|
          dump_out.each_line do |line|
            injest_in.puts(line)
          end
          raise 'rails db -p failed' unless injest_status.value.success?
        end
      end
      raise 'pg_dump failed' unless dump_status.value.success?
    end
  end
end
