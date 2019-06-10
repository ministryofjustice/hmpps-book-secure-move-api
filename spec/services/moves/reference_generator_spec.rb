# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ReferenceGenerator do
  subject(:generator) { described_class.new }

  before { srand 1 }

  let(:existing_reference) { '12345678' }
  let!(:move) { create :move, reference: existing_reference }

  it 'generates a new reference' do
    expect(generator.call).to eql 'JUWPTYK6'
  end

  it 'generates a different reference on each call' do
    references = Array.new(10).map { generator.call }
    expect(references.uniq.length).to be 10
  end

  context 'when there is a clash with an existing reference' do
    let(:existing_reference) { 'JUWPTYK6' }

    it 'generates a different reference' do
      expect(generator.call).not_to eql 'JUWPTYK6'
    end
  end
end
