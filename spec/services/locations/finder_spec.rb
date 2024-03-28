# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Finder do
  subject(:location_finder) do
    described_class.new(
      filter_params:,
      sort_params:,
      active_record_relationships:,
    )
  end

  let(:supplier) { create(:supplier) }
  let(:region) { create(:region) }
  let(:location1) { create(:location, :court, nomis_agency_id: 'COURT001') }
  let(:location2) { create(:location, :prison, nomis_agency_id: 'PRISON002') }
  let(:other_location) { create(:location, :police, nomis_agency_id: 'POLICE003') }

  let(:sort_params) { {} }
  let(:filter_params) { {} }
  let(:active_record_relationships) { [] }

  describe 'filtering' do
    context 'with location_type and nomis_agency filters' do
      before do
        location1
        location2
        other_location
      end

      context 'with a single location_type' do
        let(:filter_params) { { location_type: 'court' } }

        it 'returns locations with matching location_type' do
          expect(location_finder.call.pluck(:id)).to contain_exactly(location1.id)
        end
      end

      context 'with multiple location_types' do
        let(:filter_params) { { location_type: 'prison,court' } }

        it 'returns locations with matching location_type' do
          expect(location_finder.call.pluck(:id)).to match_array([location1.id, location2.id])
        end
      end

      context 'with a single nomis_agency' do
        let(:filter_params) { { nomis_agency_id: 'COURT001' } }

        it 'returns locations with matching nomis_agency_id' do
          expect(location_finder.call.pluck(:id)).to contain_exactly(location1.id)
        end
      end

      context 'with multiple nomis_agencies' do
        let(:filter_params) { { nomis_agency_id: 'COURT001,PRISON002' } }

        it 'returns locations with matching nomis_agency_id' do
          expect(location_finder.call.pluck(:id)).to match_array([location1.id, location2.id])
        end
      end
    end

    context 'with a supplier' do
      let(:filter_params) { { supplier_id: supplier.id } }

      before do
        create(:location) # Not linked to supplier
        create(:supplier_location, supplier:, location: other_location, effective_to: Date.yesterday) # Not effective today
        create(:supplier_location, supplier:, location: location1) # Linked and effective
        create(:supplier_location, supplier:, location: location2) # Linked and effective
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

    context 'with a created_at' do
      let(:filter_params) { { created_at: '2020-05-06' } }

      before do
        create(:location, title: '2020-05-06 Location', created_at: Time.zone.local(2020, 5, 6, 23, 59, 59))
        create(:location, title: '2020-05-07 Location', created_at: Time.zone.local(2020, 5, 7, 0, 0, 0))
      end

      it 'returns locations with specified id' do
        expect(location_finder.call.pluck(:created_at)).to contain_exactly(Time.zone.local(2020, 5, 6, 23, 59, 59))
      end
    end

    context 'with young_offender_institution true' do
      let(:filter_params) { { young_offender_institution: true } }

      before do
        create(:location, young_offender_institution: true, title: 'YOI Location')
        create(:location, young_offender_institution: false, title: 'Non YOI')
      end

      it 'returns only YOI locations' do
        expect(location_finder.call.pluck(:title)).to contain_exactly('YOI Location')
      end
    end

    context 'with young_offender_institution false' do
      let(:filter_params) { { young_offender_institution: false } }

      before do
        create(:location, young_offender_institution: true, title: 'YOI Location')
        create(:location, young_offender_institution: false, title: 'Non YOI')
      end

      it 'returns only non-YOI locations' do
        expect(location_finder.call.pluck(:title)).to contain_exactly('Non YOI')
      end
    end
  end

  describe 'sorting' do
    context 'when by title' do
      before do
        create :location, title: 'location1'
        create :location, title: 'location2'
        create :location, title: 'location3'
      end

      let(:sort_params) { { by: :title, direction: :asc } }

      it 'orders by location title' do
        expect(location_finder.call.pluck(:title)).to eql(%w[location1 location2 location3])
      end
    end

    context 'when by category' do
      let(:category1) { create :category, title: 'Category A' }
      let(:sort_params) { { by: :category, direction: :asc } }
      let(:category2) { create :category, title: 'Category B' }

      before do
        create :location, title: 'Location1', category: category1
        create :location, title: 'Location2', category: category2
        create :location, title: 'Location3', category: category1
        create :location, title: 'Location4'
      end

      it 'orders by category title then location title' do
        expect(location_finder.call.pluck(:title)).to eql(%w[Location1 Location3 Location2 Location4])
      end
    end
  end
end
