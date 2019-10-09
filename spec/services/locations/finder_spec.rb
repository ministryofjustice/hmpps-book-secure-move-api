# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Finder do
  subject(:location_finder) { described_class.new(filter_params) }

  let(:supplier) { create(:supplier) }
  let(:location) { create(:location) }

  describe 'filtering' do
    context 'with a supplier' do
      let(:filter_params) { { supplier_id: supplier.id } }

      before do
        location.suppliers << supplier
      end

      it 'returns locations matching the supplier' do
        expect(location_finder.call.pluck(:id)).to eql [location.id]
      end
    end
  end
end
