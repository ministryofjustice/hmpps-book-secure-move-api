# frozen_string_literal: true

RSpec.describe Reason do
  subject(:reason) { create(:reason) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:key) }
end
