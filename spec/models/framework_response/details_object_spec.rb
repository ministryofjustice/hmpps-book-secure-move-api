# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::DetailsObject, type: :model do
  context 'with validations' do
    it 'ignores other keys passed in' do
      attributes = { options: 'No', details: 'some comment' }
      details_object = described_class.new(attributes:, question_options: %w[No])

      expect(details_object).not_to be_valid
      expect(details_object.errors.messages[:option]).to eq(["can't be blank"])
    end

    it 'validates the presence of an option' do
      attributes = { details: 'some comment' }
      details_object = described_class.new(attributes:)

      expect(details_object).not_to be_valid
      expect(details_object.errors.messages[:option]).to eq(["can't be blank"])
    end

    it 'validates values included in option if question options are supplied' do
      attributes = { option: 'Yes' }
      details_object = described_class.new(attributes:, question_options: %w[No])

      expect(details_object).not_to be_valid
      expect(details_object.errors.messages[:option]).to eq(['is not included in the list'])
    end

    it 'does not validate the inclusion of an option if no question options supplied' do
      attributes = { option: 'Yes' }
      details_object = described_class.new(attributes:)

      expect(details_object).to be_valid
    end

    it 'validates the presence of details if detail options are supplied' do
      attributes = { option: 'No' }
      details_object = described_class.new(attributes:, details_options: %w[No])

      expect(details_object).not_to be_valid
      expect(details_object.errors.messages[:details]).to eq(["can't be blank"])
    end

    it 'does not validate the presence of details if no detail options supplied' do
      attributes = { option: 'No' }
      details_object = described_class.new(attributes:, question_options: %w[No])

      expect(details_object).to be_valid
    end

    it 'does not validate the presence of details if detail options supplied but option is answered different' do
      attributes = { option: 'Yes' }
      details_object = described_class.new(attributes:, details_options: %w[No])

      expect(details_object).to be_valid
    end
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      attributes = {
        option: 'Yes',
        details: 'some comment',
      }
      details_object = described_class.new(attributes:)

      expect(details_object.as_json).to eq(attributes)
    end

    it 'returns an empty hash if nothing passed in' do
      details_object = described_class.new(attributes: {})

      expect(details_object.as_json).to be_empty
    end

    it 'returns an empty hash if nil option and details passed in' do
      attributes = {
        option: nil,
        details: nil,
      }
      details_object = described_class.new(attributes:)

      expect(details_object.as_json).to be_empty
    end

    it 'returns details as a string if different type passed in' do
      attributes = {
        option: nil,
        details: ['Level 1', { "option": 'details' }],
      }
      details_object = described_class.new(attributes:)

      expect(details_object.as_json).to eq(details: '["Level 1", {option: "details"}]', option: nil)
    end
  end
end
