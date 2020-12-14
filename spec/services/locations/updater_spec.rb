# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Updater do
  subject(:updater) { described_class.call }

  context 'with young_offender_institution locations' do
    it 'leaves existing YOI locations unchanged' do
      existing_young_offender_institution = create(:location, young_offender_institution: true, nomis_agency_id: 'WYI')
      updater
      expect(existing_young_offender_institution.reload.young_offender_institution).to eq true
    end

    it 'clears flag on retired YOI locations' do
      retired_young_offender_institution = create(:location, young_offender_institution: true, nomis_agency_id: 'FOO')
      updater
      expect(retired_young_offender_institution.reload.young_offender_institution).to eq false
    end

    it 'sets flag on new retired YOI locations' do
      new_young_offender_institution = create(:location, young_offender_institution: false, nomis_agency_id: 'WNI')
      updater
      expect(new_young_offender_institution.reload.young_offender_institution).to eq true
    end

    it 'leaves existing non YOI locations unchanged' do
      non_young_offender_institution = create(:location, young_offender_institution: false, nomis_agency_id: 'BAR')
      updater
      expect(non_young_offender_institution.reload.young_offender_institution).to eq false
    end
  end
end
