# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  describe '#build_from_nomis' do
    subject(:category) { described_class.new.build_from_nomis(nomis_booking_details) }

    let(:nomis_booking_details) { { category: 'Cat A', category_code: 'A' } }

    it { expect(category.id).to eql('A') }
    it { expect(category.title).to eql('Cat A') }
    it { expect(category.move_supported).to be(false) }
  end
end
