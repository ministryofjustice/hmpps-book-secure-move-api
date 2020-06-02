RSpec.describe People::Importer do
  subject(:service) { described_class.new(nomis_attributes) }

  let(:nomis_attributes) do
    {
      prison_number: 'G8872UH',
      latest_booking_id: 1_093_139,
      last_name: 'JAVAS',
      first_name: "EF'LIAICO",
      middle_names: 'MATTHEWS BARNARDOS',
      date_of_birth: '1989-10-01',
      aliases: nil,
      pnc_number: '05/886838E',
      cro_number: '610592/05U',
      gender: 'foo',
      ethnicity: 'bar',
      nationalities: 'British',
    }
  end
  let!(:gender) { create(:gender, nomis_code: 'foo') }
  let!(:ethnicity) { create(:ethnicity, title: 'bar') }

  describe '#call' do
    let(:now) { Time.zone.now }

    let(:expected_person_attributes) do
      {
        'id' => nil,
        'created_at' => nil,
        'updated_at' => nil,
        'nomis_prison_number' => 'G8872UH',
        'prison_number' => 'G8872UH',
        'criminal_records_office' => '610592/05U',
        'police_national_computer' => '05/886838E',
        'first_names' => "EF'LIAICO MATTHEWS BARNARDOS",
        'last_name' => 'JAVAS',
        'date_of_birth' => Date.parse('1989-10-01'),
        'gender_additional_information' => nil,
        'gender_id' => gender.id,
        'ethnicity_id' => ethnicity.id,
        'last_synced_with_nomis' => be_within(2.seconds).of(now),
      }
    end
    let(:expected_profile_attributes) do
      {
        'id' => nil,
        'person_id' => nil,
        'last_name' => 'JAVAS',
        'first_names' => "EF'LIAICO MATTHEWS BARNARDOS",
        'date_of_birth' => Date.parse('1989-10-01'),
        'aliases' => nil,
        'gender_id' => gender.id,
        'ethnicity_id' => ethnicity.id,
        'nationality_id' => nil,
        'created_at' => nil,
        'updated_at' => nil,
        'assessment_answers' => [],
        'gender_additional_information' => nil,
        'latest_nomis_booking_id' => 1_093_139,
      }
    end

    it 'initializes a new Person' do
      person = service.call.person

      expect(person).to be_a(Person)
      expect(person).not_to be_persisted
    end

    it 'initializes a new Profile' do
      profile = service.call

      expect(profile).to be_a(Profile)
      expect(profile).not_to be_persisted
    end

    it 'assigns the correct attributes for the `Person`' do
      person = service.call.person

      expect(person.attributes).to include(expected_person_attributes)
    end

    it 'assigns the correct attributes for the `Profile`' do
      profile = service.call

      expect(profile.attributes).to include(expected_profile_attributes)
    end

    it 'assigns the correct profile_identifiers for the `Profile`' do
      actual_identifiers = JSON.parse(service.call.attributes.to_json).fetch('profile_identifiers')
      expected_identifiers = [
        { 'identifier_type' => 'police_national_computer', 'value' => '05/886838E' },
        { 'identifier_type' => 'prison_number', 'value' => 'G8872UH' },
        { 'identifier_type' => 'criminal_records_office', 'value' => '610592/05U' },
      ]

      expect(actual_identifiers).to match_array(expected_identifiers)
    end

    context 'when called for an already saved `Person` and `Profile`' do
      let!(:person) { profile.person }

      let(:profile) do
        profile = service.call
        profile.save
        profile.reload
      end

      it 'returns the same persisted `Person`' do
        expect(service.call.person).to eq(person)
      end

      # TODO: This is broken behaviour. Updates to a profile should effectively be a new profile for the person
      it 'returns the same persisted `Profile`' do
        expect(service.call).to eq(profile)
      end
    end
  end
end
