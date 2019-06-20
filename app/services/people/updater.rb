# frozen_string_literal: true

module People
  class Updater < People::Crud
    attr_accessor :id, :params, :profile, :person

    def initialize(id, params)
      self.id = id
      super(params)
    end

    def call
      self.person = Person.find(id)
      update(person)
    end

    private

    def update(person)
      Profile.transaction do
        update_profile(person.latest_profile)
      end
    end

    def update_profile(profile)
      profile.update!(
        profile_params.merge(relationships).merge(assessment_answers).merge(profile_identifiers)
      )
    end
  end
end
