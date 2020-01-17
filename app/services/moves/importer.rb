# frozen_string_literal: true

module Moves
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      import_people
      import_moves
    end

  private

    def import_people
      people_nomis_prison_numbers = items.map { |item| item.fetch(:person_nomis_prison_number) }
      people = NomisClient::People.get(people_nomis_prison_numbers).map { |p| [p.fetch(:prison_number), p] }.to_h
      alerts = NomisClient::Alerts.get(people_nomis_prison_numbers).group_by { |p| p.fetch(:offender_no) }
      personal_care_needs = NomisClient::PersonalCareNeeds
                            .get(people_nomis_prison_numbers)
                            .group_by { |p| p.fetch(:offender_no) }

      new_person_count = 0
      changed_profile_count = 0
      people.each do |offender_no, person_data|
        profile = People::Importer.new(person_data).call
        new_person_count += 1 if profile.new_record?
        profile.save!
        Alerts::Importer.new(profile: profile, alerts: alerts.fetch(offender_no, [])).call
        PersonalCareNeeds::Importer.new(profile: profile,
                                        personal_care_needs: personal_care_needs.fetch(offender_no, [])).call
        if profile.changed?
          changed_profile_count += 1
          profile.save!
        end
      end
      if new_person_count.positive? || changed_profile_count.positive?
        Rails.logger.info("[Moves::Importer] created #{new_person_count} updated #{changed_profile_count}")
      end
    end

    def import_moves
      new_count = 0
      update_count = 0
      items.map { |m| move_params(m) }.each do |move|
        new_move = Move.new(move)
        existing_move = Move.find_by(nomis_event_ids: [move[:nomis_event_id]]) || new_move.existing
        if existing_move
          existing_move.assign_attributes(move)
          if existing_move.changed?
            update_count += 1
            existing_move.save!
          end
        else
          new_count += 1
          new_move.save!
        end
      end
      if new_count.positive? || update_count.positive?
        Rails.logger.info("[Moves::Importer] #{new_count} new moves updated #{update_count} moves")
      end
    end

    def move_params(move)
      move.slice(:date, :time_due, :status, :nomis_event_id).merge(
        person: Person.find_by(nomis_prison_number: move[:person_nomis_prison_number]),
        from_location: Location.find_by(nomis_agency_id: move[:from_location_nomis_agency_id]),
        to_location: Location.find_by(nomis_agency_id: move[:to_location_nomis_agency_id]),
      )
    end
  end
end
