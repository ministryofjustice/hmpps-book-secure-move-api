# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ReferenceGenerator do
  subject(:generator) { described_class.new }

  it 'generates a new reference' do
    expect(generator.call).not_to be_nil
  end

  it 'generates a different reference on each call' do
    references = Array.new(10).map { generator.call }
    expect(references.uniq.length).to be 10
  end
end
