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
        last_name: 'Roberts',
      }
    end

    context 'with a valid assessment answer' do
      before do
        profile.assessment_answers = [
          { assessment_question_id: assessment_question.id },
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
          { key: 'foo' },
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
          identifier_type: 'police_national_computer',
        },
      ]
    end

    it 'serializes profile identifiers correctly' do
      profile.profile_identifiers = profile_identifiers
      profile.save
      reloaded_profile = described_class.find(profile.id)
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
          expires_at: Date.civil(2019, 6, 30),
          nomis_alert_code: nil,
          nomis_alert_type: nil,
          nomis_alert_description: nil,
          nomis_alert_type_description: nil,
          imported_from_nomis: false,
        },
      ]
    end
    let(:expected_attributes) do
      assessment_answers.first.merge(category: 'health', key: 'sight_impaired')
    end

    it 'serializes assessment answers correctly' do
      profile.assessment_answers = assessment_answers
      profile.save
      reloaded_profile = described_class.find(profile.id)
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

  describe '#merge_assessment_answers!' do
    subject(:profile) { build :profile, assessment_answers: assessment_answers }

    let(:assessment_answers) do
      [
        Profile::AssessmentAnswer.new(
          key: 'hold_separately',
          imported_from_nomis: false,
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          key: 'ABC',
          imported_from_nomis: true,
          nomis_alert_type: 'A',
          nomis_alert_code: 'ABC',
          description: 'NOMIS imported item A',
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          key: 'XYZ',
          imported_from_nomis: true,
          nomis_alert_type: 'X',
          nomis_alert_code: 'XYZ',
          description: 'NOMIS imported item X',
          category: 'health',
        ),
        Profile::AssessmentAnswer.new(
          key: 'not_for_release',
          imported_from_nomis: false,
          category: 'health',
        ),
      ]
    end

    let(:imported_assessment_answers) do
      [
        Profile::AssessmentAnswer.new(
          key: 'DEF',
          imported_from_nomis: true,
          nomis_alert_type: 'D',
          nomis_alert_code: 'DEF',
          description: 'NOMIS imported item #2',
          category: 'health',
        ),
        Profile::AssessmentAnswer.new(
          key: 'HIJ',
          imported_from_nomis: true,
          nomis_alert_type: 'H',
          nomis_alert_code: 'HIJ',
          description: 'NOMIS imported item #3',
          category: 'health',
        ),
      ]
    end
    let(:category) { 'health' }

    before do
      profile.merge_assessment_answers!(imported_assessment_answers, category)
    end

    it 'overwrites previously imported answers and leaves other as they were' do
      expect(profile.assessment_answers.map(&:key)).to match_array(
        %w[not_for_release hold_separately ABC DEF HIJ],
      )
    end
  end

  context 'with versioning' do
    let(:profile) { create(:profile) }

    it 'has a create event' do
      expect(profile.versions.map(&:event)).to eq(%w[create])
    end
  end
end
