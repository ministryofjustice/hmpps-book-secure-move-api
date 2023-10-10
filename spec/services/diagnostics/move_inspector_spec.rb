require 'rails_helper'

RSpec.describe Diagnostics::MoveInspector do
  subject { described_class.new(move, include_person_details:, include_per_history:).generate }

  let(:person) { create(:person) }
  let(:profile) { create(:profile, person:) }
  let(:move) { create(:move, :in_transit, :court_appearance, profile:, from_location: sch) }
  let(:person_escort_record) { create(:person_escort_record, profile:, move:) }
  let(:youth_risk_assessment) { create(:youth_risk_assessment, profile:, move:) }
  let(:journey) { create(:journey, move:) }
  let(:include_person_details) { false }
  let(:include_per_history) { false }
  let(:journey_event) { create(:event_journey_start, eventable: journey) }
  let(:move_event) { create(:event_move_start, eventable: move) }
  let(:sch) { create(:location, :sch) }
  let(:webhook) { create(:notification, :webhook, topic: move) }
  let(:email) { create(:notification, :email, topic: person_escort_record) }

  before do
    move
    move_event
    journey
    journey_event
    person
    profile
    person_escort_record
    youth_risk_assessment
    webhook
    email
  end

  it { is_expected.to match(/id:\s+#{move.id}/) }
  it { is_expected.to match(/reference:\s+#{move.reference}/) }
  it { is_expected.to match(/move type:\s+court_appearance/) }
  it { is_expected.to match(/status:\s+in_transit/) }
  it { is_expected.to match(/#{journey.id}/) }
  it { is_expected.to include(webhook.subscription.callback_url) }
  it { is_expected.to include(email.subscription.email_address) }

  context 'when include_person_details=false' do
    let(:include_person_details) { false }

    it { is_expected.not_to match(/PERSON/) }
    it { is_expected.not_to match(/PROFILE/) }
    it { is_expected.not_to match(/ASSESSMENT ANSWERS/) }
    it { is_expected.not_to match(/PERSON ESCORT RECORD/) }
    it { is_expected.not_to match(/YOUTH RISK ASSESSMENT/) }
    it { is_expected.not_to match(/id:\s+#{person.id}/) }
    it { is_expected.not_to match(/id:\s+#{profile.id}/) }
    it { is_expected.not_to match(/PERSON ESCORT RECORD HISTORY/) }

    context 'when include_per_history=true' do
      let(:include_per_history) { true }

      it { is_expected.not_to match(/PERSON ESCORT RECORD HISTORY/) }
    end
  end

  context 'when include_person_details=true' do
    let(:include_person_details) { true }

    it { is_expected.to match(/PERSON/) }
    it { is_expected.to match(/PROFILE/) }
    it { is_expected.to match(/ASSESSMENT ANSWERS/) }
    it { is_expected.to match(/PERSON ESCORT RECORD/) }
    it { is_expected.to match(/YOUTH RISK ASSESSMENT/) }
    it { is_expected.to match(/id:\s+#{person.id}/) }
    it { is_expected.to match(/id:\s+#{profile.id}/) }

    it { is_expected.not_to match(/PERSON ESCORT RECORD HISTORY/) }

    context 'when include_per_history=true' do
      let(:include_per_history) { true }

      it { is_expected.to match(/PERSON ESCORT RECORD HISTORY/) }
    end
  end
end
