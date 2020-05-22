# frozen_string_literal: true

module Moves
  class ImportPeople
    attr_accessor :prison_numbers

    def initialize(prison_numbers)
      self.prison_numbers = prison_numbers
    end

    def call
      import_people
    end

  private

    def import_people
      people = NomisClient::People.get(prison_numbers).index_by { |p| p.fetch(:prison_number) }
      alerts = NomisClient::Alerts.get(prison_numbers).group_by { |p| p.fetch(:offender_no) }
      personal_care_needs = NomisClient::PersonalCareNeeds
                            .get(prison_numbers)
                            .group_by { |p| p.fetch(:offender_no) }

      new_person_count = 0
      changed_profile_count = 0
      people.each do |offender_no, person_data|
        profile = People::Importer.new(person_data).call

        new_person_count += 1 if profile.new_record?

        Alerts::Importer.new(profile: profile, alerts: alerts.fetch(offender_no, [])).call

        PersonalCareNeeds::Importer.new(profile: profile, personal_care_needs: personal_care_needs.fetch(offender_no, [])).call

        if profile.changed?
          changed_profile_count += 1
          profile.save!
        end
      end
      if new_person_count.positive? || changed_profile_count.positive?
        Rails.logger.info("[Moves::Importer] people new[#{new_person_count}] updated[#{changed_profile_count}]")
      end
    end
  end
end
