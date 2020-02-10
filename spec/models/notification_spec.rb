# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to belong_to(:topic) }
  it { is_expected.to validate_presence_of(:time_stamp) }
  it { is_expected.to validate_presence_of(:event_type) }
  it { is_expected.to validate_presence_of(:topic) }
end
