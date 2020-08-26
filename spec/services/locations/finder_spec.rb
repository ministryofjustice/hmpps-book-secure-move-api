# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Finder do
  subject(:location_finder) { described_class.new(filter_params) }

  let(:supplier) { create(:supplier) }
  let(:location1) { create(:location) }
  let(:location2) { create(:location) }
  let(:other_location) { create(:location) }

  describe 'filtering' do
    context 'with a supplier' do
      let(:filter_params) { { supplier_id: supplier.id } }

      before do
        create(:location) # Not linked to supplier
        create(:supplier_location, supplier: supplier, location: other_location, effective_to: Date.yesterday) # Not effective today
        create(:supplier_location, supplier: supplier, location: location1) # Linked and effective
        create(:supplier_location, supplier: supplier, location: location2) # Linked and effective
      end

      it 'returns currently effective locations linked to the supplier' do
        expect(location_finder.call.pluck(:id)).to contain_exactly(location1.id, location2.id)
      end
    end
  end
end
