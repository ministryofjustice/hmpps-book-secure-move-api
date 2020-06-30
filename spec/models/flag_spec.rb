# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flag do
  subject { create(:flag) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:framework_question) }
end
