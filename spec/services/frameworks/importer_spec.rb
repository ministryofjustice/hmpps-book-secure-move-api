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

      it 'persists the same version across both frameworks' do
        described_class.new(filepath: filepath, version: '0.1').call

        expect(Framework.pluck(:version)).to contain_exactly('0.1', '0.1')
      end

      it 'persists the correct name for each framework' do
        described_class.new(filepath: filepath, version: '0.1').call

        expect(Framework.pluck(:name)).to contain_exactly(
          'person-escort-record',
          'youth-risk-assessment',
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

      it 'does not attempt to persist framework if it already exists' do
        filepath = Rails.root.join('spec/fixtures/files/frameworks/')
        described_class.new(filepath: filepath, version: '0.1').call

        expect { described_class.new(filepath: filepath, version: '0.1').call }.not_to change(Framework, :count).from(2)
      end
    end

    context 'when creating framework questions' do
      it 'persists questions relative to a framework' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework = Framework.find_by(name: 'person-escort-record')
        expect(framework.framework_questions.pluck(:key)).to contain_exactly(
          'medical-details-information',
          'medical-professional-referral',
          'medication-while-moving',
          'regular-medication',
          'sensitive-medication',
          'wheelchair-users',
          'property-bags',
          'property-bag-type',
          'property-bag-seal-number',
        )
      end

      it 'persists all the different sections for questions under a framework' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework = Framework.find_by(name: 'person-escort-record')

        expect(framework.framework_questions.pluck(:section).uniq).to contain_exactly('offence-details', 'health-information', 'property-information')
      end

      it 'maps the correct section to a question' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework_questions = Framework.find_by(name: 'person-escort-record').framework_questions

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

    context 'when creating framework questions flags' do
      it 'persists flags relative to a framework question' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework_question = FrameworkQuestion.find_by(key: 'medical-professional-referral')

        expect(framework_question.framework_flags.pluck(:title)).to contain_exactly(
          'Physical Health',
          'Medication',
        )
      end
    end

    context 'when creating framework NOMIS codes' do
      it 'persists NOMIS codes relative to a framework question' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework_question = FrameworkQuestion.find_by(key: 'wheelchair-users')

        expect(framework_question.framework_nomis_codes.pluck(:code)).to contain_exactly(
          'PEEP',
          'WHEELCHR_ACC',
        )
      end

      it 'persists NOMIS fallbacks relative to a framework question' do
        described_class.new(filepath: filepath, version: '0.1').call
        framework_question = FrameworkQuestion.find_by(key: 'medical-professional-referral')

        expect(framework_question.framework_nomis_codes.where(fallback: true).pluck(:code_type)).to contain_exactly(
          'alert',
          'personal_care_need',
        )
      end
    end
  end
end
