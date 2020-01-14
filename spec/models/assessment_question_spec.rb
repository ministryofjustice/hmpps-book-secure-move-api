# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentQuestion do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_inclusion_of(:category).in_array(described_class.categories.values) }

  it 'does not allow a blank category' do
    expect(build(:assessment_question, category: nil)).not_to be_valid
  end
end
