# frozen_string_literal: true

RSpec.shared_context 'with mock prisoner-search-api' do
  before do
    create(:gender, nomis_code: 'M', title: 'Male')
    create(:ethnicity, title: 'White British')

    allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(prison_number: 'G8133UA').and_return({
      prison_number: 'G8133UA',
      first_name: 'John',
      last_name: 'Smith',
      date_of_birth: '1980-01-01',
      latest_booking_id: 889_765, # Changed to match existing wiremock stub
      pnc_number: '12/345678A',
      cro_number: '123456/80A',
      gender: 'Male',
      ethnicity: 'White British',
      nationalities: 'British',
      aliases: [],
      middle_names: 'James',
    })

    allow(AlertsApiClient::Alerts).to receive(:get).with(prison_number: 'G8133UA').and_return([])
  end
end
