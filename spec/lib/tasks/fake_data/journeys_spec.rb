# frozen_string_literal: true

require 'rails_helper'
require 'tasks/fake_data/journeys'

RSpec.describe Tasks::FakeData::Journeys do
  subject(:create_journeys) { generator.call(number_of_journeys) }

  let(:generator) { described_class.new(move) }
  let(:supplier) { create :supplier }

  let(:from_location) { create(:location, suppliers: [supplier]) }
  let(:intermediate_locations) { create_list(:location, number_of_journeys, suppliers: [supplier]) }
  let(:to_location) { create(:location, suppliers: [supplier]) }

  let(:move) { create(:move, from_location: from_location, to_location: to_location) }
  let(:number_of_journeys) { 3 }

  # create necessary intermediate_locations before the tests run
  before { intermediate_locations }

  it 'creates fake journeys' do
    create_journeys
    # NB: there could be more than number_of_journeys as redirecting and redirecting back results in 2 journeys
    expect(move.journeys.count).to be >= number_of_journeys
  end

  context 'when move redirect occurs' do
    before do
      allow(generator).to receive(:random_event).and_return(:redirect_move_billable)
    end

    it 'creates 2 redirect events' do
      expect { create_journeys }.to change { GenericEvent::MoveRedirect.where(eventable: move).count }.from(0).to(2)
    end
  end
end
