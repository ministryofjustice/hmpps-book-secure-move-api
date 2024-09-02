require 'rails_helper'

RSpec.describe People::ImportFromNomis do
  context 'when the person is present in NOMIS', :with_nomis_client_authentication do
    subject(:import) { described_class.new([prison_number, non_existent_prison_number]) }

    let(:response_status) { '200' }
    let(:response_body) { file_fixture('nomis/post_prisoners_200.json').read }

    let(:prison_number) do
      JSON.parse(response_body).first['offenderNo'] # G3239GV
    end
    let(:non_existent_prison_number) { 'foo' }

    context 'when the Person exists in the database' do
      before do
        create(:person, prison_number:, first_names: before_first_name)
      end

      let(:before_first_name) { 'foo' }
      let(:after_first_name) { 'AVEILKE' }

      let(:expected_person) {}

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
          'criminal_records_office' => '018053/82G',
          'police_national_computer' => '82/18053V',
          'nomis_prison_number' => prison_number,
          'prison_number' => prison_number,
          'latest_nomis_booking_id' => 20_305,
          'date_of_birth' => Date.parse('15 Oct 1965'),
          'ethnicity_id' => ethnicity.id,
          'first_names' => 'AVEILKE',
          'gender_additional_information' => nil,
          'gender_id' => gender.id,
          'last_name' => 'ABBELLA',
          'last_synced_with_nomis' => be_within(4.seconds).of(Time.zone.now),
        }
      end
      let!(:gender) {  create(:gender, nomis_code: 'M') }
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
  end
end
