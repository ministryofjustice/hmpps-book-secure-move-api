# frozen_string_literal: true

module Moves
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      import_people
      import_alerts
      import_personal_care_needs
      items.each do |move|
        import_move(move)
      end
    end

    private

    def people_nomis_prison_numbers
      items.map { |item| item[:person_nomis_prison_number] }
    end

    def import_people
      NomisClient::People.get(people_nomis_prison_numbers).each do |person_attributes|
        People::Importer.new(person_attributes).call
      end
    end

    def import_alerts
      NomisClient::Alerts.get(people_nomis_prison_numbers).each do |alert_attributes|
        person = Person.find_by(nomis_prison_number: alert_attributes[:offender_no])
        Alerts::Importer.new(profile: person.latest_profile, alerts: [alert_attributes]).call
      end
    end

    def import_personal_care_needs
      NomisClient::PersonalCareNeeds.get(people_nomis_prison_numbers).each do |personal_care_needs_attributes|
        person = Person.find_by(personal_care_needs_attributes['offender_no'])
        PersonalCareNeeds::Importer.new(
          profile: person.latest_profile,
          personal_care_needs: personal_care_needs_attributes
        ).call
      end
    end

    def import_move(move)
      return if update_move_with_same_nomis_event_id(move)

      new_move = Move.new(move_params(move))
      existing_move = new_move.existing

      if existing_move
        existing_move.update(move_params(move))
      else
        new_move.save
      end
    end

    def update_move_with_same_nomis_event_id(move)
      same_nomis_event_id_move = Move.find_by_nomis_event_ids([move[:nomis_event_id]])
      same_nomis_event_id_move&.update(move_params(move))
    end

    def move_params(move)
      move.slice(:date, :time_due, :status, :nomis_event_id).merge(
        person: Person.find_by(nomis_prison_number: move[:person_nomis_prison_number]),
        from_location: Location.find_by(nomis_agency_id: move[:from_location_nomis_agency_id]),
        to_location: Location.find_by(nomis_agency_id: move[:to_location_nomis_agency_id])
      )
    end
  end
end
