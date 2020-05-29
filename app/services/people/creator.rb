# frozen_string_literal: true

module People
  class Creator < People::Crud
    attr_reader :person, :profile

    def call
      Profile.transaction do
        create_person
        create_profile
        profile.save!
      end
    end

  private

    def create_person
      @person = Person.new(
        person_params
          .merge(relationships)
          .merge(person_identifiers),
      )
    end

    def create_profile
      @profile = Profile.new(
        profile_params
          .merge(person: person)
          .merge(relationships)
          .merge(assessment_answers)
          .merge(profile_identifiers),
      )
    end
  end
end
