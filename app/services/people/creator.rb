# frozen_string_literal: true

module People
  class Creator
    attr_accessor :params, :profile

    def initialize(params)
      self.params = params
    end

    def call
      create_profile
    end

    def person
      profile&.person
    end

    PROFILE_ATTRIBUTES = %i[first_names last_name date_of_birth].freeze

    private

    def create_profile
      Profile.transaction do
        self.profile = Profile.new(profile_params.merge(person: Person.new))
        profile.save!
      end
    end

    def profile_params
      params[:attributes].slice(*PROFILE_ATTRIBUTES)
    end
  end
end
