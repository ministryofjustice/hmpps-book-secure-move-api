module Profiles
  class ImportAlertsAndPersonalCareNeeds
    def self.call(profile, prison_number)
      alerts = NomisClient::Alerts.get([prison_number]).group_by { |p| p.fetch(:offender_no) }
      personal_care_needs = NomisClient::PersonalCareNeeds.get([prison_number]).group_by { |p| p.fetch(:offender_no) }

      Alerts::Importer.new(profile: profile, alerts: alerts.fetch(prison_number, [])).call
      PersonalCareNeeds::Importer.new(profile: profile, personal_care_needs: personal_care_needs.fetch(prison_number, [])).call

      profile
    end
  end
end
