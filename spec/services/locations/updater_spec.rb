# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Updater do
  subject(:updater) { described_class.call }

  context 'with yoi locations' do
    it 'leaves existing YOI locations unchanged' do
      existing_yoi = create(:location, yoi: true, nomis_agency_id: 'WYI')
      updater
      expect(existing_yoi.reload.yoi).to eq true
    end

    it 'clears flag on retired YOI locations' do
      retired_yoi = create(:location, yoi: true, nomis_agency_id: 'FOO')
      updater
      expect(retired_yoi.reload.yoi).to eq false
    end

    it 'sets flag on new retired YOI locations' do
      new_yoi = create(:location, yoi: false, nomis_agency_id: 'WNI')
      updater
      expect(new_yoi.reload.yoi).to eq true
    end

    it 'leaves existing non YOI locations unchanged' do
      non_yoi = create(:location, yoi: false, nomis_agency_id: 'BAR')
      updater
      expect(non_yoi.reload.yoi).to eq false
    end
  end
end
