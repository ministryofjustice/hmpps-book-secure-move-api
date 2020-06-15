# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  let(:person) { create(:person) }

  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  it 'has an audit' do
    expect(person.versions.map(&:event)).to eq(%w[create])
  end

  it 'gets an image attached' do
    person.attach_image('image_data')

    expect(person.image.attached?).to be true
    expect(person.image.filename).to eq "#{person.id}.jpg"
  end
end
