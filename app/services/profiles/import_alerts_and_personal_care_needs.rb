module Profiles
  class ImportAlertsAndPersonalCareNeeds
    def initialize(profile, prison_number)
      @profile = profile
      @prison_number = prison_number
    end

    def call
      Alerts::Importer.new(profile: @profile, alerts: alerts.fetch(@prison_number, [])).call
      PersonalCareNeeds::Importer.new(profile: @profile, personal_care_needs: personal_care_needs.fetch(@prison_number, [])).call

      @profile.save!
    end

  private

    def personal_care_needs
      { @prison_number => PrisonerSearchApiClient::PersonalCareNeeds.get(prison_number: @prison_number) }
    end

    def alerts
      AlertsApiClient::Alerts.get(prison_number: @prison_number).group_by { |p| p.fetch(:prison_number) }
    end
  end
end
