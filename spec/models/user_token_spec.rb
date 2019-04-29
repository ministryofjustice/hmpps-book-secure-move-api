# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserToken, type: :model do
  it { is_expected.to validate_presence_of(:access_token) }
  it { is_expected.to validate_presence_of(:refresh_token) }
  it { is_expected.to validate_presence_of(:expires_at) }
  it { is_expected.to validate_presence_of(:user_name) }
  it { is_expected.to validate_presence_of(:user_id) }
end
