# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to validate_inclusion_of(:value_type).in_array(%w[string array text json]) }

  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:person_escort_record) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
  it { is_expected.to have_and_belong_to_many(:flags) }

  it 'validates absence of value text if response type is array' do
    response = create(:framework_response, value_type: 'array')

    expect(response).to validate_absence_of(:value_text)
  end

  it 'validates absence of value text if response type is json' do
    response = create(:framework_response, value_type: 'json')

    expect(response).to validate_absence_of(:value_text)
  end

  it 'validates absence of value json if response type is string' do
    response = create(:framework_response, value_type: 'string')

    expect(response).to validate_absence_of(:value_json)
  end

  it 'validates absence of value json if response type is text' do
    response = create(:framework_response, value_type: 'text')

    expect(response).to validate_absence_of(:value_json)
  end

  describe '#value' do
    it 'returns the response value if type is string' do
      response = create(:framework_response, value_type: 'string', value: 'Yes')

      expect(response.value).to eq('Yes')
    end

    it 'returns the response value if type is array' do
      response = create(
        :framework_response,
        value_type: 'array',
        value: ['Level 1', 'Level 2'],
      )

      expect(response.value).to contain_exactly('Level 1', 'Level 2')
    end

    it 'returns the response value if type is text' do
      response = create(
        :framework_response,
        value_type: 'text',
        value: 'Some text here that should probably be longer',
      )

      expect(response.value).to eq('Some text here that should probably be longer')
    end

    it 'returns the response value if type is json' do
      response = create(
        :framework_response,
        value_type: 'json',
        value: {
          value: 'Yes',
          comment: 'Some text',
        },
      )

      expect(response.value).to eq('value' => 'Yes', 'comment' => 'Some text')
    end

    it 'returns a nil response value if type is string and its empty' do
      response = create(:framework_response, value_type: 'string', value: nil)

      expect(response.value).to be_nil
    end

    it 'returns a nil response value if type is text and its empty' do
      response = create(:framework_response, value_type: 'text', value: nil)

      expect(response.value).to be_nil
    end

    it 'returns an empty response value if type is json and its set as empty' do
      response = create(:framework_response, value_type: 'json', value: {})

      expect(response.value).to eq('{}')
    end

    it 'returns an empty response value if type is array and its set as empty' do
      response = create(:framework_response, value_type: 'array', value: [])

      expect(response.value).to be_empty
    end

    it 'returns an empty response value if type is json and its empty' do
      response = create(:framework_response, value_type: 'json')

      expect(response.value).to eq('{}')
    end

    it 'returns an empty response value if type is array and its empty' do
      response = create(:framework_response, value_type: 'array')

      expect(response.value).to be_empty
    end
  end
end
