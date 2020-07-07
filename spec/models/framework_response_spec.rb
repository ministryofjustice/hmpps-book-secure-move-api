# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:person_escort_record) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }

  it 'sets correct type to framework response when object' do
    create(:object_response)

    expect(described_class.first).to be_a(FrameworkResponse::Object)
  end

  it 'sets correct type to framework response when collection' do
    create(:collection_response)

    expect(described_class.first).to be_a(FrameworkResponse::Collection)
  end

  it 'sets correct type to framework response when string' do
    create(:string_response)

    expect(described_class.first).to be_a(FrameworkResponse::String)
  end

  it 'sets correct type to framework response when array' do
    create(:array_response)

    expect(described_class.first).to be_a(FrameworkResponse::Array)

  end
end
