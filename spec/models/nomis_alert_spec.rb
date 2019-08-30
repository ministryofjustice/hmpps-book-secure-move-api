# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisAlert do
  it { is_expected.to validate_presence_of(:type_code) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:type_description) }
  it { is_expected.to validate_presence_of(:description) }
end
