# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:location_type) }

  context 'when location is a prison' do
    subject(:location) { build :location }

    it { expect(location.prison?).to be true }
    it { expect(location.police?).to be false }
    it { expect(location.court?).to be false }
  end

  context 'when location is a police custody unit' do
    subject(:location) { build :location, :police }

    it { expect(location.prison?).to be false }
    it { expect(location.police?).to be true }
    it { expect(location.court?).to be false }
  end

  context 'when location is a court' do
    subject(:location) { build :location, :court }

    it { expect(location.prison?).to be false }
    it { expect(location.police?).to be false }
    it { expect(location.court?).to be true }
  end
end
