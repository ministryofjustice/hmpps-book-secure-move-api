# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisAlert do
  it { is_expected.to validate_presence_of(:nomis_alert_type) }
  it { is_expected.to validate_presence_of(:nomis_alert_code) }
  it { is_expected.to validate_presence_of(:nomis_alert_type_description) }
  it { is_expected.to validate_presence_of(:nomis_alert_code_description) }
end
