# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  let(:person) { create(:person) }

  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves) }


  it 'has an audit' do
    expect(person.versions.map(&:event)).to eq(%w[create])
  end
end
