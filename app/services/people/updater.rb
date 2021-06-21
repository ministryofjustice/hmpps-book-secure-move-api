# frozen_string_literal: true

module People
  class Updater < People::Crud
    attr_reader :person

    def initialize(person, params)
      @person = person
      @profile = person.latest_profile
      @params = params
      super(params)
    end

    def call
      Profile.transaction do
        update_person
        update_profile
      end
    end

  private

    attr_reader :params, :profile

    def update_person
      person.update!(
        person_params.merge(person_relationships).merge(person_identifiers),
      )
    end

    def update_profile
      profile.update!(profile_assessment_answers)
    end
  end
end
