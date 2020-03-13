# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  let(:person) { create(:person) }

  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves) }

  it 'has an audit' do
    expect(person.versions.map(&:event)).to eq(%w[create])
  end

  it 'gets a picture attached' do
    person.attach_image('image_data')

    expect(person.picture.attached?).to be true
    expect(person.picture.filename).to eq "#{person.id}.jpg"
  end
end
