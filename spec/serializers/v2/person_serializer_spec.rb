# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::PersonSerializer do
  subject(:serializer) { described_class.new(person, adapter_options) }

  let(:person) { create :person, gender_additional_information: 'additional information' }
  let(:adapter_options) { {} }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'people'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql person.id
  end

  it 'contains a first_names attribute' do
    expect(result[:data][:attributes][:first_names]).to eql person.first_names
  end

  it 'contains a last_name attribute' do
    expect(result[:data][:attributes][:last_name]).to eql person.last_name
  end

  it 'contains a date_of_birth attribute' do
    expect(result[:data][:attributes][:date_of_birth]).to eql person.date_of_birth.iso8601
  end

  it 'contains a gender_additional_information attribute' do
    expect(result[:data][:attributes][:gender_additional_information]).to eql person.gender_additional_information
  end

  it 'contains a prison_number attribute' do
    expect(result[:data][:attributes][:prison_number]).to eql person.prison_number
  end

  it 'contains a criminal_records_office attribute' do
    expect(result[:data][:attributes][:criminal_records_office]).to eql person.criminal_records_office
  end

  it 'contains a police_national_computer attribute' do
    expect(result[:data][:attributes][:police_national_computer]).to eql person.police_national_computer
  end

  describe 'ethnicity' do
    let(:adapter_options) { { include: %i[ethnicity] } }

    it 'contains a relationship to ethnicity' do
      expect(result[:data][:relationships]).to include(:ethnicity)
    end

    context 'with the ethnicity' do
      it 'contains an included ethnicity' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('ethnicities')
      end
    end

    context 'without the ethnicity' do
      let(:person) { create(:person, ethnicity: nil) }

      it 'does not contain an included ethnicity' do
        expect(result[:included]).to be_empty
      end
    end
  end

  describe 'gender' do
    let(:adapter_options) { { include: %i[gender] } }

    it 'contains a relationship to gender' do
      expect(result[:data][:relationships]).to include(:gender)
    end

    context 'with the gender' do
      it 'contains an included gender' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('genders')
      end
    end

    context 'without the gender' do
      let(:person) { create(:person, gender: nil) }

      it 'does not contain an included gender' do
        expect(result[:included]).to be_empty
      end
    end
  end

  describe 'profiles' do
    let(:adapter_options) { { include: %i[profiles] } }

    it 'contains a relationship to profiles' do
      expect(result[:data][:relationships]).to include(:profiles)
    end

    context 'with profiles' do
      it 'contains an included gender' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('profiles')
      end
    end

    context 'without profiles' do
      let(:person) { create(:person, profiles: []) }

      it 'does not contain included profiles' do
        expect(result[:included]).to be_empty
      end
    end
  end

  describe 'generic_events' do
    let(:adapter_options) { { include: %i[events] } }

    context 'with generic events' do
      let(:now) { Time.zone.now }
      let!(:first_event) { create(:event_person_move_assault, eventable: person, occurred_at: now + 2.seconds) }
      let!(:second_event) { create(:event_person_move_serious_injury, eventable: person, occurred_at: now + 1.second) }
      let!(:third_event) { create(:event_person_move_death_in_custody, eventable: person, occurred_at: now) }

      let(:expected_event_relationships) do
        [
          { id: third_event.id, type: 'events' },
          { id: second_event.id, type: 'events' },
          { id: first_event.id, type: 'events' },
        ]
      end

      it 'contains event relationships' do
        expect(result[:data][:relationships][:events]).to eq(data: expected_event_relationships)
      end

      it 'contains included events' do
        expect(result[:included].map { |event| event[:id] }).to match_array([third_event.id, second_event.id, first_event.id])
      end
    end

    context 'without generic events' do
      it 'contains an empty allocation' do
        expect(result[:data][:relationships][:events]).to eq(data: [])
      end

      it 'does not contain an included event' do
        expect(result[:included]).to be_blank
      end
    end
  end
end
