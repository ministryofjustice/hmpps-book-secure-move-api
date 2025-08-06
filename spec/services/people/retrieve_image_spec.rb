# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveImage do
  let(:person) { create(:person, prison_number: 'A1234AA') }

  before do
    allow(PrisonerSearchApiClient::Prisoner).to receive(:facial_image_exists?)
      .with(prison_number: 'A1234AA')
      .and_return(true)
  end

  describe '.call' do
    context 'when latest_nomis_booking_id is empty' do
      subject(:retrieve_image) { described_class.call(person) }

      before do
        person.update(latest_nomis_booking_id: nil)
      end

      it 'returns false' do
        expect(retrieve_image).to be(false)
      end
    end

    context 'when person.image.attached? is true' do
      before do
        person.latest_nomis_booking_id = 123
        person.image.attach(io: StringIO.new, filename: 'filename', content_type: 'image/jpeg')
        allow(person).to receive(:attach_image).and_return(true)
        allow(NomisClient::Image).to receive(:get).and_return('image_blob')
      end

      context 'when force_update: false' do
        it 'does not update the image' do
          described_class.call(person)

          expect(person).not_to have_received(:attach_image)
        end
      end

      context 'when force_update: true' do
        it 'updates the image' do
          described_class.call(person, force_update: true)

          expect(person).to have_received(:attach_image)
        end
      end
    end

    context 'when facial image does not exist' do
      before do
        person.latest_nomis_booking_id = 123
        allow(PrisonerSearchApiClient::Prisoner).to receive(:facial_image_exists?)
          .with(prison_number: 'A1234AA')
          .and_return(false)
        allow(NomisClient::Image).to receive(:get)
      end

      it 'returns false without calling NomisClient::Image.get' do
        result = described_class.call(person)

        expect(result).to be(false)
        expect(NomisClient::Image).not_to have_received(:get)
      end
    end
  end
end
