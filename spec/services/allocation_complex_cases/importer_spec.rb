# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationComplexCases::Importer do
  subject(:importer) { described_class.new }

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(AllocationComplexCase, :count).by(4)
    end
  end

  context 'with one existing record' do
    before do
      AllocationComplexCase.create!(key: 'mental_health_issue', title: 'Foo')
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(AllocationComplexCase, :count).by(3)
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(AllocationComplexCase.find_by(key: 'mental_health_issue', title: 'Mental health issues')).to be_present
    end
  end
end
