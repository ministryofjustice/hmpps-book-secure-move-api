require 'rails_helper'

RSpec.describe Diagnostics::MoveInspector do
  subject { described_class.new(move).generate }

  let(:move) { create(:move, :in_transit, :court_appearance) }
  let(:journey) { create(:journey, move: move) }

  before do
    journey # create the journey
  end

  it { is_expected.to match(/id:\s+#{move.id}/) }
  it { is_expected.to match(/reference:\s+#{move.reference}/) }
  it { is_expected.to match(/move type:\s+court_appearance/) }
  it { is_expected.to match(/status:\s+in_transit/) }
  it { is_expected.to match(/#{journey.id}/) }
end
