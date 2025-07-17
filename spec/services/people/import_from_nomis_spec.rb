require 'rails_helper'

RSpec.describe People::ImportFromNomis do
  context 'when the person is present in Prisoner Search', :with_hmpps_authentication, :with_prisoner_search_api do
    subject(:import) { described_class.new([prison_number]) }

    let(:response_status) { '200' }
    let(:response_body) { file_fixture('prisoner_search_api/get_prisoner_200.json').read }
    let(:prison_number) do
      JSON.parse(response_body)['prisonerNumber'] # A1234AA
    end

    context 'when the Person exists in the database' do
      before do
        create(:person, prison_number:, first_names: before_first_name)
      end

      let(:before_first_name) { 'foo' }
      let(:after_first_name) { 'Robert' }

      it 'does not create a new Person' do
        expect { import.call }.not_to change(Person, :count)
      end

      it 'updates the existing person' do
        person = Person.find_by(prison_number:)
        expect { import.call }.to change { person.reload.first_names }.from(before_first_name).to(after_first_name)
      end
    end

    context 'when the Person does NOT exist in the database' do
      let(:expected_attributes) do
        {
          'criminal_records_office' => '29906/12J',
          'police_national_computer' => '12/394773H',
          'nomis_prison_number' => prison_number,
          'prison_number' => prison_number,
          'latest_nomis_booking_id' => 1_200_924, # Integer, not string
          'date_of_birth' => Date.parse('1975-04-02'),
          'ethnicity_id' => ethnicity.id,
          'first_names' => 'Robert',
          'gender_additional_information' => nil,
          'gender_id' => gender_female.id,
          'last_name' => 'Larsen',
          'last_synced_with_nomis' => be_within(4.seconds).of(Time.zone.now),
        }
      end

      let!(:gender_female) { create(:gender) }
      let!(:ethnicity) { create(:ethnicity, title: 'White: Eng./Welsh/Scot./N.Irish/British') }

      it 'creates a Person with the correct attributes' do
        import.call
        person = Person.find_by(prison_number:)
        expect(person.attributes).to include(expected_attributes)
      end

      it 'creates a new Person' do
        expect { import.call }.to change(Person, :count).by(1)
      end
    end

    context 'when API call fails for a prison number' do
      subject(:import) { described_class.new([prison_number, failing_prison_number]) }

      let(:failing_prison_number) { 'INVALID' }

      before do
        # Mock the API to return nil for the failing prison number
        allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(failing_prison_number).and_return(nil)
        allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(prison_number).and_call_original
      end

      it 'creates person for successful call and skips failed call' do
        expect { import.call }.to change(Person, :count).by(1)
        expect(Person.find_by(prison_number:)).to be_present
        expect(Person.find_by(prison_number: failing_prison_number)).to be_nil
      end
    end

    context 'when multiple prison numbers are provided' do
      subject(:import) { described_class.new([prison_number, prison_number_2]) }

      let(:prison_number_2) { 'B5678CD' }
      let!(:ethnicity) { create(:ethnicity, title: 'White: Eng./Welsh/Scot./N.Irish/British') }

      before do
        # Mock the second prison number to return nil (not found)
        allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(prison_number_2).and_return(nil)
        allow(PrisonerSearchApiClient::Prisoner).to receive(:get).with(prison_number).and_call_original
      end

      it 'only creates person for valid prison number' do
        expect { import.call }.to change(Person, :count).by(1)
        expect(Person.find_by(prison_number:)).to be_present
        expect(Person.find_by(prison_number: prison_number_2)).to be_nil
      end
    end
  end
end
