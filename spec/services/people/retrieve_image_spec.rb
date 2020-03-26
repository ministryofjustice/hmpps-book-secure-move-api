# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveImage do
  subject(:retrieve_image) { described_class.call(person) }

  let(:person) { build(:person) }

  it 'returns false if latest_nomis_booking_id is empty' do
    person.latest_profile.update(latest_nomis_booking_id: nil)

    expect(retrieve_image).to eq(false)
  end
end
