# frozen_string_literal: true

RSpec.describe Ethnicity do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:title) }
end
