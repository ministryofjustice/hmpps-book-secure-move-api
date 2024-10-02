# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentQuestions::Importer do
  subject(:importer) { described_class.new }

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(AssessmentQuestion, :count).by(18)
    end

    it 'creates `Violent`' do
      importer.call
      expect(AssessmentQuestion.find_by(key: 'violent', category: 'risk', title: 'Violent')).to be_present
    end

    it 'creates `Pregnant`.' do
      importer.call
      expect(AssessmentQuestion.find_by(key: 'pregnant', category: 'health', title: 'Pregnant')).to be_present
    end

    it 'creates `Interpreter`' do
      importer.call
      expect(
        AssessmentQuestion.find_by(key: 'interpreter', category: 'court', title: 'Sign or other language interpreter'),
      ).to be_present
    end
  end

  context 'with one existing record' do
    before do
      AssessmentQuestion.create!(key: 'pregnant', category: 'health', title: 'Pregnant')
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(AssessmentQuestion, :count).by(17)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:other_court) do
      AssessmentQuestion.create!(key: 'other_court', category: 'court', title: 'Any other info')
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(other_court.reload.title).to eq 'Any other information'
    end
  end
end
