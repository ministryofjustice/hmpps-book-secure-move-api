# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Finder do
  subject(:location_finder) { described_class.new(filter_params, sort_params) }

  let(:supplier) { create(:supplier) }
  let(:region) { create(:region) }
  let(:location1) { create(:location) }
  let(:location2) { create(:location) }
  let(:other_location) { create(:location) }

  let(:sort_params) { {} }
  let(:filter_params) { {} }

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

    context 'with a region' do
      let(:filter_params) { { region_id: region.id } }

      before do
        create(:location) # Not linked to region
        region.locations = [location1, location2]
      end

      it 'returns locations within the specified region' do
        expect(location_finder.call.pluck(:id)).to contain_exactly(location1.id, location2.id)
      end
    end

    context 'with a location' do
      let(:filter_params) { { location_id: location1.id } }

      it 'returns locations with specified id' do
        expect(location_finder.call.pluck(:id)).to contain_exactly(location1.id)
      end
    end
  end

  describe 'sorting' do
    let!(:location1) { create :location, title: 'LOCATION1' }
    let!(:location2) { create :location, title: 'Location2' }
    let!(:location3) { create :location, title: 'LOCATION3' }
    let(:sort_params) { { by: :title, direction: :asc } }

    it 'orders by location title (case-sensitive)' do
      expect(location_finder.call.pluck(:title)).to eql(%w[LOCATION1 LOCATION3 Location2]) # NB: case-sensitive order
    end
  end
end
