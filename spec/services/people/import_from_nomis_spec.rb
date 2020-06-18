RSpec.describe People::ImportFromNomis do
  # {:prison_number=>"G5033UT", :latest_booking_id=>1059832, :last_name=>"SMITH", :first_name=>"DELBERT", :middle_names=>"JOHN", :date_of_birth=>"1958-04-07", :aliases=>nil, :pnc_number=>"73/9524M", :cro_number=>"9524/73C", :gender=>"M", :ethnicity=>nil, :nationalities=>"British"}


  context 'when the person is present in NOMIS', with_nomis_client_authentication: true do
    subject(:import) { described_class.new(prison_number) }

    let(:response_status) { '200' }
    let(:response_body) { file_fixture('nomis_post_prisoners_200.json').read }

    let(:prison_number) {
      JSON.parse(response_body).first['offenderNo'] # G3239GV
    }

    it 'creates a new Person' do
      expect{ import.call }.to change{
         Person.count
      }.by(1)
    end

    context 'when person is NOT already present' do
      before do
        create(:person, prison_number: 'G3239GV')
      end

      it 'does not create a new Person' do
        expect{ import.call }.to change{
          Person.count
        }.by(0)
      end

      it 'updates the existent person' do
        import.call

        updated_person = Person.find_by(prison_number: 'G3239GV')

        expect(updated_person.first_names).to eq('AVEILKE')
      end
    end

  end

  context 'when the person is not present' do

  end
end
