# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::BaseCollection, type: :model do
  subject(:base_collection) { described_class.new }

  describe '#concrete_class' do
    it 'raises an exception if not implemented in descendant class' do
      expect { base_collection.concrete_class }.to raise_error(NotImplementedError)
    end
  end

  describe '#remove_empty_items?' do
    it 'is disabled unless overridden in descendant class' do
      expect(base_collection.remove_empty_items?).to be false
    end
  end
end
