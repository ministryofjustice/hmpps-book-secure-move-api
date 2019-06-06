# frozen_string_literal: true

module People
  class Creator
    attr_accessor :params

    def initialize(params)
      self.params = params
    end

    def call
      profile = create_profile
      profile.person
    end

    PROFILE_ATTRIBUTES = %i[first_names last_name date_of_birth].freeze

    private

    def create_profile
      Profile.create!(profile_params.merge(person: Person.create!))
    end

    def profile_params
      params[:attributes].slice(*PROFILE_ATTRIBUTES)
    end
  end
end
