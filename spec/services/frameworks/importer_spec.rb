# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Frameworks::Importer do
  describe '#call' do
    let(:filepath) { Rails.root.join('spec/fixtures/files/frameworks/') }

    context 'when creating frameworks' do
      it 'persists multiple frameworks' do
        described_class.new(filepath: filepath, version: '0.1').call

        expect(Framework.count).to eq(2)
      end

      it 'persists the version of the framework' do
        described_class.new(filepath: filepath, version: '0.1').call

        expect(Framework.find_by(name: 'person-escort-record-1')).to have_attributes(
          version: '0.1',
        )
      end

      it 'does not persist framework if no version provided' do
        expect { described_class.new(filepath: filepath, version: nil).call }.not_to change(Framework, :count).from(0)
      end

      it 'does not persist framework if no base filename provided' do
        described_class.new(filepath: nil, version: '0.1').call
        expect { described_class.new(filepath: nil, version: '0.1').call }.not_to change(Framework, :count).from(0)
      end

      it 'does not persist any framework records if they are invalid' do
        filepath = Rails.root.join('spec/fixtures/files/invalid-framework/')
        described_class.new(filepath: filepath, version: '0.1').call
      rescue ActiveRecord::RecordInvalid
        expect(Framework.count).to be_zero
      end
    end

    context 'when creating framework questions' do
      it 'persists questions relative to a framework' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework = Framework.find_by(name: 'person-escort-record-1')
        expect(framework.framework_questions.pluck(:key)).to contain_exactly(
          'medical-details-information',
          'medical-professional-referral',
          'medication-while-moving',
          'regular-medication',
          'sensitive-medication',
          'wheelchair-users',
        )
      end

      it 'persists all the different sections for questions under a framework' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework = Framework.find_by(name: 'person-escort-record-1')

        expect(framework.framework_questions.pluck(:section).uniq).to contain_exactly('offence-details', 'health-information')
      end

      it 'maps the correct section to a question' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework_questions = Framework.find_by(name: 'person-escort-record-1').framework_questions

        expect(framework_questions.where(section: 'health-information').pluck(:key)).to contain_exactly(
          'medical-details-information',
          'medical-professional-referral',
          'medication-while-moving',
          'regular-medication',
          'sensitive-medication',
        )
      end

      it 'maps followup questions to parent questions' do
        described_class.new(filepath: filepath, version: '0.1').call

        question = FrameworkQuestion.find_by(key: 'sensitive-medication')
        expect(question.dependents).to contain_exactly(FrameworkQuestion.find_by(key: 'medication-while-moving'))
      end

      it 'maps all next section questions to parent question' do
        described_class.new(filepath: filepath, version: '0.1').call

        question = FrameworkQuestion.find_by(key: 'regular-medication')
        expect(question.dependents).to contain_exactly(FrameworkQuestion.find_by(key: 'medical-details-information'))
      end
    end
  end
end
