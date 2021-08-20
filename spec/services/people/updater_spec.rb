# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Updater do
  subject(:updater) { described_class.new(person, params) }

  let(:risk_type_1) { create :assessment_question, :risk }
  let(:risk_type_2) { create :assessment_question, :risk }
  let(:original_profile_attributes) do
    {
      assessment_answers: [
        { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
      ],
      person: person,
    }
  end
  let(:pnc) { "17/1553#{Person.pnc_checkdigit('170001553')}" }
  let(:original_person_attributes) do
    {
      first_names: 'Robbie',
      last_name: 'Roberts',
      date_of_birth: Date.civil(1980, 6, 1),
      police_national_computer: pnc,
    }
  end
  let(:person) { create(:person, original_person_attributes) }
  let(:profile) { create(:profile, original_profile_attributes) }
  let(:params) do
    {
      type: 'people',
      attributes: {
        first_names: 'Alice',
        date_of_birth: Date.civil(1980, 1, 1),
      },
    }
  end

  let(:updated_person) { person.reload }
  let(:updated_profile) { updated_person.latest_profile }

  before do
    person.latest_profile.update(original_profile_attributes)
  end

  context 'with valid input params' do
    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'does not create a new Profile' do
      expect(person.profiles.count).to be 1
    end

    it 'sets the correct Person attributes' do
      expect(updated_person.attributes.with_indifferent_access).to include(params[:attributes])
    end

    it 'does not change original last_name' do
      expect(updated_person.last_name).to eq original_person_attributes[:last_name]
    end

    it 'does not change original assessment_answers' do
      expect(updated_profile.assessment_answers.map(&:title)).to match_array(
        original_profile_attributes[:assessment_answers].pluck(:title),
      )
    end

    it 'does not change original identifiers for the Person' do
      expect(updated_person.police_national_computer).to eq(pnc)
    end
  end

  context 'with valid input params including nested data' do
    let(:params) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.civil(1980, 1, 1),
          assessment_answers: [
            { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
            { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
          ],
          identifiers: [
            { identifier_type: 'police_national_computer', value: pnc },
            { identifier_type: 'prison_number', value: 'XYZ987' },
          ],
        },
      }
    end

    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'sets the identifiers attributes for the Person' do
      identifiers = params[:attributes][:identifiers]

      identifiers.each do |identifier|
        expect(updated_person.send(identifier[:identifier_type])).to eq(identifier[:value])
      end
    end

    it 'sets the assessment_answers attribute for the profile' do
      expect(updated_profile.assessment_answers.as_json).to include_json(params[:attributes][:assessment_answers])
    end
  end

  context 'with valid input params including relationships' do
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:params) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.civil(1980, 1, 1),
        },
        relationships: {
          ethnicity: {
            data: {
              id: ethnicity.id,
              type: 'ethnicities',
            },
          },
          gender: {
            data: {
              id: gender.id,
              type: 'genders',
            },
          },
        },
      }
    end

    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'sets the correct Person ethnicity' do
      expect(updated_person.ethnicity_id).to eql ethnicity.id
    end

    it 'sets the correct Person gender' do
      expect(updated_person.gender_id).to eql gender.id
    end
  end
end
