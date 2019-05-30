# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAttribute do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:profile_attribute_type) }
  it { is_expected.to validate_presence_of(:profile) }

  it { is_expected.to belong_to(:profile) }
  it { is_expected.to belong_to(:profile_attribute_type) }

  CATEGORIES = [
    %i[risk health],
    %i[health court_information],
    %i[court_information risk]
  ].freeze

  CATEGORIES.each do |category, alternate_category|
    describe "##{category}?" do
      subject(:profile_attribute) do
        create(:profile_attribute, profile_attribute_type: profile_attribute_type, profile: profile)
      end

      let(:person) { create :person }
      let(:profile) { person.profiles.first }

      context "when profile attribute has type category `#{category}`" do
        let(:profile_attribute_type) { create :profile_attribute_type, category }

        it 'returns true' do
          expect(profile_attribute.send("#{category}?")).to be true
        end
      end

      context "when profile attribute has type category `#{alternate_category}`" do
        let(:profile_attribute_type) { create :profile_attribute_type, alternate_category }

        it 'returns false' do
          expect(profile_attribute.send("#{category}?")).to be false
        end
      end
    end
  end
end
