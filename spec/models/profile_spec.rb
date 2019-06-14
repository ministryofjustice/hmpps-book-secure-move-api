# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to belong_to(:ethnicity).optional }
  it { is_expected.to belong_to(:gender).optional }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  describe '#profile_identifiers' do
    let!(:person) { create :person }
    let(:profile) { person.profiles.first }
    let(:profile_identifiers) do
      [
        {
          value: 'ABC123456',
          identifier_type: 'pnc_number'
        }
      ]
    end

    it 'serializes profile identifiers correctly' do
      profile.profile_identifiers = profile_identifiers
      profile.save
      reloaded_profile = Profile.find(profile.id)
      expect(reloaded_profile.profile_identifiers&.first&.as_json).to eql(profile_identifiers.first)
    end

    it 'deserializes profile identifiers to an array' do
      profile.profile_identifiers = profile_identifiers
      expect(profile.profile_identifiers).to be_an(Array)
    end

    it 'deserializes profile identifiers to an array of ProfileIdentifier objects' do
      profile.profile_identifiers = profile_identifiers
      expect(profile.profile_identifiers.first).to be_a(Profile::ProfileIdentifier)
    end
  end

  describe '#assessment_answers' do
    let!(:person) { create :person }
    let(:profile) { person.profiles.first }
    let(:assessment_question) { create :assessment_question, category: 'health' }
    let(:assessment_answers) do
      [
        {
          title: 'test',
          comments: 'just a test',
          assessment_question_id: assessment_question.id,
          date: Date.civil(2019, 5, 30),
          expiry_date: Date.civil(2019, 6, 30)
        }
      ]
    end
    let(:expected_attributes) do
      assessment_answers.first.merge(category: 'health')
    end

    it 'serializes profile attributes correctly' do
      profile.assessment_answers = assessment_answers
      profile.save
      reloaded_profile = Profile.find(profile.id)
      expect(reloaded_profile.assessment_answers&.first&.as_json).to eql expected_attributes
    end

    it 'deserializes profile attributes to an array' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers).to be_an(Array)
    end

    it 'deserializes profile attributes to an array of AssessmentAnswer objects' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers.first).to be_a(Profile::AssessmentAnswer)
    end
  end
end
