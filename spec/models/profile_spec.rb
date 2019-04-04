# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile do
  subject(:profile) { described_class.new }

  it 'works' do
    expect(profile).to be_present
  end
end
