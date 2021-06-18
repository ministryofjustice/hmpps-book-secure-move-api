# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationValidator do
  subject(:target) do
    # anonymous class to test validation against
    Class.new {
      include ActiveModel::Validations
      attr_accessor :location

      validates_with LocationValidator, locations: [:location]

      def self.name
        'TestValidationClass'
      end
    }.new
  end

  before { target.location = location_id }

  context 'when valid' do
    let(:location_id) { create(:location).id }

    it { is_expected.to be_valid }
  end

  context "when location doesn't exist" do
    let(:location_id) { 'nowhere' }

    it 'is not valid' do
      expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
      expect(target.errors.full_messages).to match_array('Location was not found')
    end
  end

  context 'when location is nil' do
    let(:location_id) { nil }

    it 'is not valid' do
      expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
      expect(target.errors.full_messages).to match_array('Location is missing')
    end
  end
end
