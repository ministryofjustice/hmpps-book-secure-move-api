# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  subject(:person) { create(:person) }

  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves).through(:profiles) }
  it { is_expected.to have_many(:person_escort_records).through(:profiles) }
  it { is_expected.to have_many(:youth_risk_assessments).through(:profiles) }
  it { is_expected.to have_many(:generic_events) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  it 'has an audit' do
    expect(person.versions.map(&:event)).to eq(%w[create])
    person.update(first_names: 'Finbarr', last_name: 'Saunders')
    expect(person.versions.map(&:event)).to eq(%w[create update])
  end

  it 'gets an image attached' do
    person.attach_image('image_data')

    expect(person.image.attached?).to be true
    expect(person.image.filename).to eq "#{person.id}.jpg"
  end

  describe '#police_national_computer' do
    it 'is case insensitive' do
      person = create(:person, police_national_computer: 'FLIBBLE')
      expect(described_class.where(police_national_computer: 'flibble')).to include(person)
    end

    it 'stores blank values as nil' do
      person = create(:person, police_national_computer: '')
      expect(person.reload.police_national_computer).to be_nil
    end
  end

  describe '#criminal_records_office' do
    it 'is case insensitive' do
      person = create(:person, criminal_records_office: 'FLIBBLE')
      expect(described_class.where(criminal_records_office: 'flibble')).to include(person)
    end

    it 'stores blank values as nil' do
      person = create(:person, criminal_records_office: '')
      expect(person.reload.criminal_records_office).to be_nil
    end
  end

  describe '#prison_number' do
    it 'is case insensitive' do
      person = create(:person, prison_number: 'FLIBBLE')
      expect(described_class.where(prison_number: 'flibble')).to include(person)
    end

    it 'stores blank values as nil' do
      person = create(:person, prison_number: '')
      expect(person.reload.prison_number).to be_nil
    end
  end

  # TODO: Remove nomis_prison_number once we remove v1 from our system
  describe '#nomis_prison_number' do
    it 'is case insensitive' do
      person = create(:person, nomis_prison_number: 'FLIBBLE')
      expect(described_class.where(nomis_prison_number: 'flibble')).to include(person)
    end

    it 'stores blank values as nil' do
      person = create(:person, nomis_prison_number: '')
      expect(person.reload.nomis_prison_number).to be_nil
    end
  end

  describe '#for_feed' do
    subject(:person) { create(:person) }

    let(:expected_json) do
      {
        'id' => person.id,
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'criminal_records_office' => person.criminal_records_office,
        'nomis_prison_number' => person.nomis_prison_number,
        'police_national_computer' => person.police_national_computer,
        'prison_number' => person.prison_number,
        'latest_nomis_booking_id' => person.latest_nomis_booking_id,
        'age' => person.age,
        'first_names' => person.first_names,
        'last_name' => person.last_name,
        'date_of_birth' => be_a(Date),
      }
    end

    it 'generates a feed document' do
      expect(person.for_feed).to include_json(expected_json)
    end
  end

  describe '#latest_person_escort_record' do
    it 'does not return anything if no person escort record found for person' do
      expect(person.latest_person_escort_record).to be_nil
    end

    it 'does not return anything if no confirmed person escort record found for person' do
      create(:person_escort_record, profile: person.profiles.first)

      expect(person.latest_person_escort_record).to be_nil
    end

    it 'returns a confirmed person escort record for a person' do
      profile1 = create(:profile, person: person)
      profile2 = create(:profile, person: person)
      confirmed_person_escort_record = create(:person_escort_record, :confirmed, profile: profile1)
      create(:person_escort_record, profile: profile2)

      expect(person.latest_person_escort_record).to eq(confirmed_person_escort_record)
    end

    it 'returns the newest confirmed person escort record for a person' do
      profile1 = create(:profile, person: person)
      profile2 = create(:profile, person: person)
      newest_person_escort_record = create(:person_escort_record, :confirmed, confirmed_at: Time.zone.today, profile: profile1)
      create(:person_escort_record, :confirmed, confirmed_at: Time.zone.yesterday, profile: profile2)

      expect(person.latest_person_escort_record).to eq(newest_person_escort_record)
    end
  end

  describe '#latest_youth_risk_assessment' do
    it 'does not return anything if no youth risk assessment found for person' do
      expect(person.latest_youth_risk_assessment).to be_nil
    end

    it 'does not return anything if no confirmed youth risk assessment found for person' do
      create(:youth_risk_assessment, profile: person.profiles.first)

      expect(person.latest_youth_risk_assessment).to be_nil
    end

    it 'returns a confirmed youth risk assessment for a person' do
      profile1 = create(:profile, person: person)
      profile2 = create(:profile, person: person)
      confirmed_youth_risk_assessment = create(:youth_risk_assessment, :confirmed, profile: profile1)
      create(:youth_risk_assessment, profile: profile2)

      expect(person.latest_youth_risk_assessment).to eq(confirmed_youth_risk_assessment)
    end

    it 'returns the newest confirmed youth risk assessment for a person' do
      profile1 = create(:profile, person: person)
      profile2 = create(:profile, person: person)
      newest_youth_risk_assessment = create(:youth_risk_assessment, :confirmed, confirmed_at: Time.zone.today, profile: profile1)
      create(:youth_risk_assessment, :confirmed, confirmed_at: Time.zone.yesterday, profile: profile2)

      expect(person.latest_youth_risk_assessment).to eq(newest_youth_risk_assessment)
    end
  end

  context 'when the date of birth is before 1900-01-01' do
    it 'fails with an error' do
      expect { create(:person, :pre1900) }.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Birth date must be after 1900-01-01.')
    end
  end

  describe '#update_nomis_data' do
    let(:import_alerts_and_personal_care_needs) { instance_double('Profiles::ImportAlertsAndPersonalCareNeeds', call: true) }

    before do
      allow(Profiles::ImportAlertsAndPersonalCareNeeds).to receive(:new).and_return(import_alerts_and_personal_care_needs)
      allow(People::RetrieveImage).to receive(:call)
    end

    it "updates the person's image" do
      person.update_nomis_data

      expect(People::RetrieveImage).to have_received(:call).with(person, force_update: true).once
    end

    context 'when the person has a prison number' do
      before do
        person.instance_variable_set(:@prison_number, 123)
      end

      it "updates the person's alerts and personal needs" do
        person.update_nomis_data

        expect(import_alerts_and_personal_care_needs).to have_received(:call).once
      end
    end
  end
end
