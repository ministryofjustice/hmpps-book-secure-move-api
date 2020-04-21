# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComplexCases::Importer do
  subject(:importer) { described_class.new }

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(ComplexCase, :count).by(4)
    end
  end

  context 'with one existing record' do
    before do
      ComplexCase.create!(key: 'mental', title: 'Foo')
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(ComplexCase, :count).by(3)
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(ComplexCase.find_by(key: 'mental', title: 'Mental health issues')).to be_present
    end
  end
end
