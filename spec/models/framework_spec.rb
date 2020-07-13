# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Framework do
  subject { create(:framework) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:version) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:version) }
  it { is_expected.to have_many(:person_escort_records) }
  it { is_expected.to have_many(:framework_questions) }

  describe '.ordered_by_latest_version' do
    it 'orders frameworks by descending order of versions' do
      framework1 = create(:framework, version: '1.01')
      framework2 = create(:framework, version: '0.1')
      framework3 = create(:framework, version: '1.12')

      expect(described_class.ordered_by_latest_version).to eq(
        [framework3, framework1, framework2],
      )
    end
  end
end
