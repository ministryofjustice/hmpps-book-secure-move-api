# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::DetailsObject, type: :model do
  it 'validates the presence of an option' do
    attributes = { details: 'some comment' }
    details_object = described_class.new(attributes: attributes)

    expect(details_object).not_to be_valid
  end

  it 'validates the inclusion of an option if question options are supplied' do
    attributes = { option: 'Yes' }
    details_object = described_class.new(attributes: attributes, question_options: %w[No])

    expect(details_object).not_to be_valid
  end

  it 'does not validate the inclusion of an option if no question options supplied' do
    attributes = { option: 'Yes' }
    details_object = described_class.new(attributes: attributes)

    expect(details_object).to be_valid
  end

  it 'validates the presence of details if detail options are supplied' do
    attributes = { option: 'No' }
    details_object = described_class.new(attributes: attributes, details_options: %w[No])

    expect(details_object).not_to be_valid
  end

  it 'does not validate the presence of details if no detail options supplied' do
    attributes = { option: 'No' }
    details_object = described_class.new(attributes: attributes, question_options: %w[No])

    expect(details_object).to be_valid
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      attributes = {
        option: 'Yes',
        details: 'some comment',
      }
      details_object = described_class.new(attributes: attributes)

      expect(details_object.as_json).to eq(attributes)
    end

    it 'returns a hash of nil values of nothing passed in' do
      attributes = {
        option: nil,
        details: nil,
      }
      details_object = described_class.new(attributes: {})

      expect(details_object.as_json).to eq(attributes)
    end
  end
end
