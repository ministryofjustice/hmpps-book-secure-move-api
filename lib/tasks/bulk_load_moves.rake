# frozen_string_literal: true

require_relative 'bulk_load/client'

namespace :bulk do
  desc 'bulk loads moves via api'
  task :load_moves, [:number, :from_location, :to_location, :move_type, :base_url, :client_id, :client_secret] => :environment do |_, args|

    # rake 'bulk:load_moves[1,b3e75d13-1f93-407f-8e80-719c4b3d3f42,8fa68589-8ded-435c-b0c1-ffcade5f1bef,court_appearance,http://localhost:5001/,XXX,XXX]'
    #
    # Forest Gate Custody Suite LOCAL = b3e75d13-1f93-407f-8e80-719c4b3d3f42
    # Westminster Magistrates LOCAL = 8fa68589-8ded-435c-b0c1-ffcade5f1bef
    # Forest Gate Custody Suite UAT = 02ae2375-8f79-4c15-aa4f-e219e467c885
    # Westminster Magistrates UAT = 067104b7-432a-4ca9-8e58-22d49772f08d

    abort "specify number" unless args[:number].present?
    abort "specify from_location" unless args[:from_location].present?
    abort "specify to_location" unless args[:to_location].present?
    abort "specify move_type" unless args[:move_type].present?
    abort "specify client_id" unless args[:client_id].present?
    abort "specify client_secret" unless args[:client_secret].present?

    puts "Creating #{args[:number]} #{args[:move_type]} moves from #{args[:from_location]} to #{args[:to_location]} on #{args[:base_url]}"

    total = args[:number].to_i
    client = Tasks::BulkLoad::Client.new(args[:client_id], args[:client_secret], args[:base_url])

    gender_ids = client.get('/api/reference/genders').map{ |g| g['id'] }
    ethnicity_ids = client.get('/api/reference/ethnicities').map{|e| e['id'] }

    start_time = Time.zone.now
    n = 1
    loop do
      person_data = {
        "data": {
          "type": "people",
          "attributes": {
            "first_names": "Person-#{n}",
            "last_name": "Test",
            "date_of_birth": "1980-02-03",
            "gender_additional_information": nil,
            "prison_number": nil,
            "police_national_computer": nil,
            "criminal_records_office": nil
          },
          "relationships": {
            "gender": {
              "data": {
                "type": "genders",
                "id": gender_ids.sample
              }
            },
            "ethnicity": {
              "data": {
                "type": "ethnicities",
                "id": ethnicity_ids.sample
              }
            }
          }
        }
      }

      profile_data = {
        "data": {
          "type": "profiles",
          "attributes": {
            "assessment_answers": []
          }
        }
      }

      person_id = client.post('/api/people', { body: person_data.to_json })['id']

      profile_id = client.post("/api/people/#{person_id}/profiles", {body: profile_data.to_json})['id']

      date = Date.tomorrow.strftime("%Y-%m-%d")

      move_data = {
        "data": {
          "type": "moves",
          "attributes": {
            "date": date,
            "time_due": "#{date}T09:00:00+01:00",
            "status": "requested",
            "additional_information": "load test move",
            "move_type": args[:move_type]
          },
          "relationships": {
            "profile": {
              "data": {
                "type": "profiles",
                "id": profile_id
              }
            },
              "from_location": {
                "data": {
                  "type": "locations",
                  "id": args[:from_location]
                }
              },
              "to_location": {
                "data": {
                  "type": "locations",
                  "id": args[:to_location]
                }
              }
          }
        }
      }

      move_id = client.post("/api/moves", {body: move_data.to_json})['id']

      abort "failed to create move" unless move_id.present?

      puts "#{n}\t#{move_id}"
      sleep (0.01)

      n += 1
      break if n > total
    end
    end_time = Time.zone.now
    elapsed = (end_time - start_time).seconds

    puts "Created #{total} moves in #{elapsed} (#{1.0 * total / elapsed } moves per second)"
  end
end
