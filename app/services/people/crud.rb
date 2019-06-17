# frozen_string_literal: true

module People
  class Crud
    attr_accessor :params, :profile

    def initialize(params)
      self.params = params
    end

    ATTRIBUTES = %i[first_names last_name date_of_birth].freeze
    PROFILE_ASSOCIATIONS = %i[gender ethnicity].freeze

    private

    def relationships
      (params[:relationships] || {}).slice(*PROFILE_ASSOCIATIONS).map do |attribute, value|
        ["#{attribute}_id", value[:data][:id]]
      end.to_h
    end

    def assessment_answers
      {
        assessment_answers: params[:attributes][:assessment_answers] || []
      }
    end

    def profile_identifiers
      {
        profile_identifiers: params[:attributes][:identifiers] || []
      }
    end

    def profile_params
      params[:attributes].slice(*ATTRIBUTES)
    end
  end
end
