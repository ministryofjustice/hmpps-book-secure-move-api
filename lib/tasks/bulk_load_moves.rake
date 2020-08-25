# frozen_string_literal: true

require_relative 'bulk_load/client'

namespace :bulk do
  desc 'bulk loads moves via api'
  task :load_moves, %i[number from_location to_location move_type base_url client_id client_secret] => :environment do |_, args|
    # e.g. rake 'bulk:load_moves[1,b3e75d13-1f93-407f-8e80-719c4b3d3f42,8fa68589-8ded-435c-b0c1-ffcade5f1bef,court_appearance,http://localhost:5001/,XXX,XXX]'
    #
    # Forest Gate Custody Suite LOCAL = b3e75d13-1f93-407f-8e80-719c4b3d3f42
    # Westminster Magistrates LOCAL = 8fa68589-8ded-435c-b0c1-ffcade5f1bef
    # Forest Gate Custody Suite UAT = 02ae2375-8f79-4c15-aa4f-e219e467c885
    # Westminster Magistrates UAT = 067104b7-432a-4ca9-8e58-22d49772f08d

    abort 'specify number' if args[:number].blank?
    abort 'specify from_location' if args[:from_location].blank?
    abort 'specify to_location' if args[:to_location].blank?
    abort 'specify move_type' if args[:move_type].blank?
    abort 'specify client_id' if args[:client_id].blank?
    abort 'specify client_secret' if args[:client_secret].blank?

    client = Tasks::BulkLoad::Client.new(args[:client_id], args[:client_secret], args[:base_url])

    gender_ids = client.get('/api/reference/genders')
                     .reject { |g| %w[nk ns].include?(g['attributes']['key']) } # some suppliers can't process unspecified gender; exclude from load test now
                     .map { |g| g['id'] }

    ethnicity_ids = client.get('/api/reference/ethnicities').map { |e| e['id'] }
    from_location_name = client.get("/api/reference/locations/#{args[:from_location]}")['attributes']['title']
    to_location_name = client.get("/api/reference/locations/#{args[:to_location]}")['attributes']['title']
    assessment_questions = client.get('/api/reference/assessment_questions')

    total = args[:number].to_i

    puts "Creating #{args[:number]} #{args[:move_type]} moves from #{from_location_name} to #{to_location_name} on #{args[:base_url]}"

    start_time = Time.zone.now
    n = 1
    loop do
      begin
        person_data = {
          "data": {
            "type": 'people',
            "attributes": {
              "first_names": "Person-#{n}",
              "last_name": 'Test',
              "date_of_birth": '1980-02-03',
              "gender_additional_information": nil,
              "prison_number": nil,
              "police_national_computer": nil,
              "criminal_records_office": nil,
            },
            "relationships": {
              "gender": {
                "data": {
                  "type": 'genders',
                  "id": gender_ids.sample,
                },
              },
              "ethnicity": {
                "data": {
                  "type": 'ethnicities',
                  "id": ethnicity_ids.sample,
                },
              },
            },
          },
        }

        assessment_question = assessment_questions.sample

        profile_data = {
          "data": {
            "type": 'profiles',
            "attributes": {
              "assessment_answers": [
                {
                  "key": assessment_question['attributes']['key'],
                  "category": assessment_question['attributes']['category'],
                  "title": assessment_question['attributes']['title'],
                  "comments": "Test Comment #{n}",
                  "assessment_question_id": assessment_question['id'],
                  "imported_from_nomis": false,
                },
              ],
            },
          },
        }

        person_id = client.post('/api/people', { body: person_data.to_json })['id']

        profile_id = client.post("/api/people/#{person_id}/profiles", { body: profile_data.to_json })['id']

        date = Date.tomorrow.strftime('%Y-%m-%d')

        move_data = {
          "data": {
            "type": 'moves',
            "attributes": {
              "date": date,
              "time_due": "#{date}T09:00:00+01:00",
              "status": 'requested',
              "additional_information": 'load test move',
              "move_type": args[:move_type],
            },
            "relationships": {
              "profile": {
                "data": {
                  "type": 'profiles',
                  "id": profile_id,
                },
              },
              "from_location": {
                "data": {
                  "type": 'locations',
                  "id": args[:from_location],
                },
              },
              "to_location": {
                "data": {
                  "type": 'locations',
                  "id": args[:to_location],
                },
              },
            },
          },
        }

        move_id = client.post('/api/moves', { body: move_data.to_json })['id']

        raise 'failed to create move' if move_id.blank?

        puts "#{n}\t#{move_id}"
        sleep(0.02)
      rescue StandardError => e
        puts "Error creating move: #{e.inspect}"
        puts 'waiting 30 seconds for system to recover'
        sleep(30)
      end

      n += 1
      break if n > total
    end
    end_time = Time.zone.now
    elapsed = (end_time - start_time).seconds

    puts "Created #{total} moves in #{elapsed} (#{1.0 * total / elapsed} moves per second)"
  end
end
