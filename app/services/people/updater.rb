# frozen_string_literal: true

module People
  class Updater < People::Creator
    attr_accessor :id, :params, :profile

    def initialize(id, params)
      self.id = id
      self.params = params
    end

    def call
      person = Person.find(id)
      update(person)
    end

    PROFILE_ATTRIBUTES = %i[first_names last_name date_of_birth].freeze
    PROFILE_ASSOCIATIONS = %i[gender ethnicity].freeze

    private

    def update(person)
      Profile.transaction do
        update_person(person)
        update_profile(person.latest_profile)
      end
    end

    def update_person(person)

    end

    def update_profile(profile)
      profile.update!(profile_params)
    end
  end
end
