# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethnicity do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:title) }
end
