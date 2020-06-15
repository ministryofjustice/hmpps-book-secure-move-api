# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::NomisPersonValidator do
  subject(:validator) { described_class.new(person) }

  context 'when latest_nomis_booking_id is empty' do
    let(:person) { Person.new(latest_nomis_booking_id: nil) }

    it { is_expected.not_to be_valid }

    it 'has errors on latest_nomis_booking_id' do
      validator.valid?

      expect(validator.errors[:latest_nomis_booking_id]).not_to be_empty
    end
  end

  context 'when latest_nomis_booking_id is present' do
    let(:person) { Person.new(latest_nomis_booking_id: 123) }

    it { is_expected.to be_valid }
  end
end
