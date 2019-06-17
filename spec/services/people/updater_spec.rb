# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Updater do
  subject(:updater) { described_class.new(person.id, params) }

  let(:person) { create :person }
  let(:params) do
    {
      type: 'people',
      attributes: {
        first_names: 'Alice',
        last_name: 'Roberts',
        date_of_birth: Date.civil(1980, 1, 1)
      }
    }
  end

  let(:updated_person) { person.reload }
  let(:updated_profile) { updated_person.latest_profile }

  context 'with valid input params' do
    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'does not create a new Profile' do
      expect(person.profiles.count).to be 1
    end

    it 'sets the correct Profile attibutes' do
      expect(updated_profile.attributes.with_indifferent_access).to include(params[:attributes])
    end
  end

  context 'with valid input params including nested data' do
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }
    let(:params) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.civil(1980, 1, 1),
          assessment_answers: [
            { title: 'Escape risk', assessment_question_id: risk_type_1.id },
            { title: 'Violent', assessment_question_id: risk_type_2.id }
          ],
          identifiers: [
            { identifier_type: 'pnc_number', value: 'ABC123' },
            { identifier_type: 'prison_number', value: 'XYZ987' }
          ]
        }
      }
    end

    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'sets the identifiers attribute' do
      expect(updated_profile.profile_identifiers.as_json).to include_json(params[:attributes][:identifiers])
    end

    it 'sets the assessment_answers attribute' do
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
          date_of_birth: Date.civil(1980, 1, 1)
        },
        relationships: {
          ethnicity: {
            data: {
              id: ethnicity.id,
              type: 'ethnicities'
            }
          },
          gender: {
            data: {
              id: gender.id,
              type: 'genders'
            }
          }
        }
      }
    end

    let!(:result) { updater.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'sets the correct Profile ethnicity' do
      expect(updated_profile.ethnicity_id).to eql ethnicity.id
    end

    it 'sets the correct Profile gender' do
      expect(updated_profile.gender_id).to eql gender.id
    end
  end
end
