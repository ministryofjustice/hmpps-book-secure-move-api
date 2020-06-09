# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HashWithIndifferentAccessSerializer do
  let(:h) { { 'a' => { 'b' => 'c' } } }

  describe 'load' do
    subject(:parsed) { described_class.load(h) }

    it { expect(parsed[:a][:b]).to eql('c') }
    it { expect(parsed['a']['b']).to eql('c') }
  end

  describe 'dump' do
    subject { described_class.dump(h) }

    it { is_expected.to eql(h) }
  end
end
