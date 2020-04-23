# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveDiaryEntries do
  let(:person) { instance_double('Person') }

  before do
    allow(People::RetrieveCourtHearings).to receive(:get).and_return(court_hearings)
    allow(People::RetrieveActivities).to receive(:get).and_return(activities)
  end

  # it 'returns an array of DiaryEntry ducks' do
  #   response = described_class.call(person)

  #   expect(response).to all(be_a(NomisCourtHearing))
  # end

  # it 'calls NomisClient::CourtHearings with the correct args' do
  #   described_class.call(person)

  #   expect(NomisClient::CourtHearings).to have_received(:get).with('12345')
  # end
end
