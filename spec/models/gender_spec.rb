# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gender do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:key) }

  describe '#prompt_for_additional_information' do
    subject(:gender) { create :gender }

    it 'defaults to false' do
      expect(gender.prompt_for_additional_information).to be false
    end
  end
end
