# frozen_string_literal: true

module People
  class Creator < People::Crud
    attr_reader :person, :profile

    def call
      Profile.transaction do
        create_person!
        create_profile!
      end
    end

  private

    def create_person!
      @person = Person.new(
        person_params
          .merge(person_relationships)
          .merge(person_identifiers),
      )
      @person.save!
    end

    def create_profile!
      @profile = Profile.new(profile_assessment_answers.merge(person:))
      @profile.save!
    end
  end
end
