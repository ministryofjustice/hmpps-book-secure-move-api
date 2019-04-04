# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  subject(:person) { described_class.new }

  it 'works' do
    expect(person).to be_present
  end
end
