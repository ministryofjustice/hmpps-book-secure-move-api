RSpec.describe People::ImportFromNomis do
  # {:prison_number=>"G5033UT", :latest_booking_id=>1059832, :last_name=>"SMITH", :first_name=>"DELBERT", :middle_names=>"JOHN", :date_of_birth=>"1958-04-07", :aliases=>nil, :pnc_number=>"73/9524M", :cro_number=>"9524/73C", :gender=>"M", :ethnicity=>nil, :nationalities=>"British"}

  context 'when the person is present in NOMIS', with_nomis_client_authentication: true do
    subject(:import) { described_class.new(prison_number) }

    let(:response_status) { '200' }
    let(:response_body) { file_fixture('nomis_post_prisoners_200.json').read }

    let(:prison_number) do
      JSON.parse(response_body).first['offenderNo'] # G3239GV
    end

    context 'when the Person exists in the database' do
      before do
        create(:person, prison_number: prison_number, first_names: before_first_name)
      end

      let(:before_first_name) { 'foo' }
      let(:after_first_name) { 'AVEILKE' }

      let(:expected_person) {}

      it 'does not create a new Person' do
        expect { import.call }.not_to change(Person, :count)
      end

      it 'updates the existing person' do
        person = Person.find_by(prison_number: prison_number)

        expect { import.call }.to change { person.reload.first_names }.from(before_first_name).to(after_first_name)
      end
    end

    context 'when the Person does NOT exist in the database' do
      let(:expected_attributes) do
        {
           "criminal_records_office" => nil,
           "date_of_birth" => Fri, 15 Oct 1965,
           "ethnicity_id" => nil,
           "first_names" => "AVEILKE",
           "gender_additional_information" => nil,
           "gender_id" => nil,
           "id" => "84cf1cc3-fd2f-4c7c-92cf-769257e11155",
           "last_name" => "ABBELLA",
           "last_synced_with_nomis" => 2020-06-18 16:13:22.772685000 +0100,
           "latest_nomis_booking_id" => nil,
           "nomis_prison_number" => prison_number,
           "police_national_computer" => nil,
           "prison_number" => "G3239GV",
        }
      end

      it 'creates a Person with the correct attributes' do
        import.call

        person = Person.find_by(prison_number: prison_number)

        expect(person.attributes).to eq(expected_attributes)
      end

      it 'creates a new Person' do
        expect { import.call }.to change(Person, :count).by(1)
      end
    end
  end

  context 'when the person is not present' do
  end
end
