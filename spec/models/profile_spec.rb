# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to belong_to(:ethnicity).optional }
  it { is_expected.to belong_to(:gender).optional }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  describe '#validate_assessment_answers' do
    subject(:profile) { described_class.new(attributes) }

    let(:attributes) do
      {
        person: create(:person),
        first_names: 'Bob',
        last_name: 'Roberts'
      }
    end

    context 'with a valid assessment answer' do
      before do
        profile.assessment_answers = [
          { assessment_question_id: assessment_question.id }
        ]
      end

      let(:assessment_question) { create :assessment_question }

      it 'the profile is valid' do
        expect(profile).to be_valid
      end
    end

    context 'with an invalid assessment answer' do
      before do
        profile.assessment_answers = [
          { key: 'foo' }
        ]
      end

      it 'the profile is invalid' do
        expect(profile).not_to be_valid
      end
    end
  end

  describe '#profile_identifiers' do
    let!(:person) { create :person }
    let(:profile) { person.profiles.first }
    let(:profile_identifiers) do
      [
        {
          value: 'ABC123456',
          identifier_type: 'police_national_computer'
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
          title: 'Sight Impaired',
          comments: 'just a test',
          assessment_question_id: assessment_question.id,
          created_at: Date.civil(2019, 5, 30),
          expiry_date: Date.civil(2019, 6, 30)
        }
      ]
    end
    let(:expected_attributes) do
      assessment_answers.first.merge(category: 'health', key: 'sight_impaired')
    end

    it 'serializes assessment answers correctly' do
      profile.assessment_answers = assessment_answers
      profile.save
      reloaded_profile = Profile.find(profile.id)
      expect(reloaded_profile.assessment_answers&.first&.as_json).to eql expected_attributes
    end

    it 'deserializes assessment answers to an array' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers).to be_an(Array)
    end

    it 'deserializes assessment answers to an array of AssessmentAnswer objects' do
      profile.assessment_answers = assessment_answers
      expect(profile.assessment_answers.first).to be_a(Profile::AssessmentAnswer)
    end
  end
end
