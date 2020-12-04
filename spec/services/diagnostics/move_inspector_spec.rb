require 'rails_helper'

RSpec.describe Diagnostics::MoveInspector do
  subject { described_class.new(move, include_person_details: include_person_details).generate }

  let(:person) { create(:person) }
  let(:profile) { create(:profile, person: person) }
  let(:move) { create(:move, :in_transit, :court_appearance, profile: profile) }
  let(:journey) { create(:journey, move: move) }
  let(:include_person_details) { false }
  let(:journey_event) { create(:event_journey_start, eventable: journey) }
  let(:move_event) { create(:event_move_start, eventable: move) }

  before do
    journey       # create the journey
    journey_event # create the journey event
    move_event    # create the move event
  end

  it { is_expected.to match(/id:\s+#{move.id}/) }
  it { is_expected.to match(/reference:\s+#{move.reference}/) }
  it { is_expected.to match(/move type:\s+court_appearance/) }
  it { is_expected.to match(/status:\s+in_transit/) }
  it { is_expected.to match(/#{journey.id}/) }

  context 'when include_person_details=false' do
    it { is_expected.not_to match(/PERSON/) }
    it { is_expected.not_to match(/PROFILE/) }
    it { is_expected.not_to match(/ASSESSMENT ANSWERS/) }
    it { is_expected.not_to match(/id:\s+#{person.id}/) }
    it { is_expected.not_to match(/id:\s+#{profile.id}/) }
  end

  context 'when include_person_details=true' do
    let(:include_person_details) { true }

    it { is_expected.to match(/PERSON/) }
    it { is_expected.to match(/PROFILE/) }
    it { is_expected.to match(/ASSESSMENT ANSWERS/) }
    it { is_expected.to match(/id:\s+#{person.id}/) }
    it { is_expected.to match(/id:\s+#{profile.id}/) }
  end
end
