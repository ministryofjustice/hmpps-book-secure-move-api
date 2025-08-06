# frozen_string_literal: true

module Moves
  class ImportPeople
    attr_accessor :prison_numbers

    def initialize(prison_numbers)
      self.prison_numbers = Array(prison_numbers)
    end

    def call
      import_people
    end

  private

    def import_people
      personal_care_needs = prison_numbers.index_with do |prison_number|
        PrisonerSearchApiClient::PersonalCareNeeds.get(prison_number)
      end

      new_person_count = 0
      changed_profile_count = 0

      prison_numbers.each do |prison_number|
        person_data = PrisonerSearchApiClient::Prisoner.get(prison_number)
        next unless person_data

        profile = People::BuildPersonAndProfileV1.new(person_data).call
        new_person_count += 1 if profile.new_record?

        alerts = AlertsApiClient::Alerts.get(prison_number)
        Alerts::Importer.new(profile:, alerts:).call

        PersonalCareNeeds::Importer.new(profile:, personal_care_needs: personal_care_needs.fetch(prison_number, [])).call

        next unless profile.changed? || profile.person.changed?

        changed_profile_count += 1
        profile.person.save!
        profile.save!
      end

      if new_person_count.positive? || changed_profile_count.positive?
        Rails.logger.info("[Moves::Importer] people new[#{new_person_count}] updated[#{changed_profile_count}]")
      end
    end
  end
end
