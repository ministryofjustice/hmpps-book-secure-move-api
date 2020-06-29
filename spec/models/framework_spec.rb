# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Framework do
  subject { create(:framework) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:version) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:version) }
end
