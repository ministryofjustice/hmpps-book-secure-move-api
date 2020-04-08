require 'rails_helper'

RSpec.describe Moves::CreateCourtHearings do
  subject(:create_court_hearings) { described_class.new(move, court_hearings_params) }

  before do
    allow(move).to receive(:from_prison_to_court?).and_return(true)
  end

  let(:move) { create(:move) }
  let(:court_hearings_params) do
    [
      {
        "start_time": "2018-01-01T18:57Z",
        "case_start_date": "2018-01-01",
        "nomis_case_id": "4232423",
        "court_type": "Adult",
        "comments": "Witness for Foo Bar"
      }
    ]
  end

  it "creates court hearings" do
    expect { create_court_hearings.call }.
      to change(CourtHearing, :count).by(1)
  end

  it "returns court hearings" do
    expect(create_court_hearings.call).
      to include(an_instance_of(CourtHearing))
  end
end
