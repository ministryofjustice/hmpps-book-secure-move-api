# frozen_string_literal: true

module People
  class Crud
    attr_accessor :params, :profile

    def initialize(params)
      self.params = params
    end

    ATTRIBUTES = %i[first_names last_name date_of_birth gender_additional_information].freeze
    PROFILE_ASSOCIATIONS = %i[gender ethnicity].freeze

  protected

    def relationships
      (params[:relationships] || {}).slice(*PROFILE_ASSOCIATIONS).map { |attribute, value|
        ["#{attribute}_id", value[:data][:id]]
      }.to_h
    end

    def assessment_answers
      params[:attributes].slice(:assessment_answers)
    end

    def profile_identifiers
      identifiers ? { profile_identifiers: identifiers } : {}
    end

    def person_identifiers
      if identifiers
        attributes = identifiers.each_with_object({}) do |identifier, acc|
          acc[identifier[:identifier_type].to_sym] = identifier[:value]
        end

        attributes.slice(*Person::IDENTIFIER_TYPES)
      else
        {}
      end
    end

    def profile_params
      params[:attributes].slice(*ATTRIBUTES)
    end
    alias_method :person_params, :profile_params

  private

    def identifiers
      @identifiers ||= params.dig(:attributes, :identifiers)
    end
  end
end
