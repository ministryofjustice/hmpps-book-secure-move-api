# frozen_string_literal: true

module People
  class Creator < People::Crud
    attr_accessor :params, :profile

    def call
      create_profile
    end

    def person
      profile&.person
    end

    private

    def create_profile
      Profile.transaction do
        self.profile = Profile.new(
          profile_params
            .merge(person: Person.new)
            .merge(relationships)
            .merge(assessment_answers)
            .merge(profile_identifiers)
        )
        profile.save!
      end
    end
  end
end
