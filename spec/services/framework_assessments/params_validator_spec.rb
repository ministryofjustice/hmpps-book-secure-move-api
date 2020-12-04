# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkAssessments::ParamsValidator do
  it 'validates status if value is not in list statuses' do
    params_validator = described_class.new('in_progress')

    expect(params_validator).not_to be_valid
    expect(params_validator.errors.messages[:status]).to eq(['is not included in the list'])
  end

  it 'does not validate status if value is confirmed' do
    params_validator = described_class.new('confirmed')

    expect(params_validator).to be_valid
  end
end
