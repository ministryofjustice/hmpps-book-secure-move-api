# frozen_string_literal: true

module People
  class Crud
    attr_accessor :params, :profile

    def initialize(params)
      self.params = params
    end

    PROFILE_ATTRIBUTES = %i[first_names last_name date_of_birth].freeze
    PROFILE_ASSOCIATIONS = %i[gender ethnicity].freeze

    private

    def relationships
      (params[:relationships] || {}).slice(*PROFILE_ASSOCIATIONS).map do |attribute, value|
        ["#{attribute}_id", value[:data][:id]]
      end.to_h
    end

    def profile_attributes
      {
        profile_attributes: risk_alerts + health_alerts + court_information
      }
    end

    def risk_alerts
      params[:attributes][:risk_alerts] || []
    end

    def health_alerts
      params[:attributes][:health_alerts] || []
    end

    def court_information
      params[:attributes][:court_information] || []
    end

    def profile_identifiers
      {
        profile_identifiers: params[:attributes][:identifiers]
      }
    end

    def profile_params
      params[:attributes].slice(*PROFILE_ATTRIBUTES)
    end
  end
end
