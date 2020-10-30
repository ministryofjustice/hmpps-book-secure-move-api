# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  subject(:category) { build(:category) }

  it { is_expected.to have_many(:locations) }
  it { is_expected.to have_many(:profiles) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:move_supported) }
end

# describe '#build_from_nomis' do
#   subject(:category) { described_class.new.build_from_nomis(nomis_booking_details) }
#
#   let(:nomis_booking_details) { { category: 'Cat A', category_code: 'A' } }
#
#   it { expect(category.id).to eql('A') }
#   it { expect(category.title).to eql('Cat A') }
#   it { expect(category.move_supported).to be(false) }
# end