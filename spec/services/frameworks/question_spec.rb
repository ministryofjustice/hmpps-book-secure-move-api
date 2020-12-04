# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Frameworks::Question do
  describe '#call' do
    let(:fixture_path) { 'spec/fixtures/files/frameworks/person-escort-record/questions' }

    it 'sets a question as required if required validation available' do
      filepath = Rails.root.join(fixture_path, 'medical-details-information.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-details-information')
      described_class.new(filepath: filepath, questions: { 'medical-details-information' => question }).call

      expect(question.required).to eq(true)
    end

    it 'sets a question as not required if no validation available' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      described_class.new(filepath: filepath, questions: { 'medical-professional-referral' => question }).call

      expect(question.required).to eq(false)
    end

    it 'sets the type on a question' do
      filepath = Rails.root.join(fixture_path, 'medical-details-information.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-details-information')
      described_class.new(filepath: filepath, questions: { 'medical-details-information' => question }).call

      expect(question.question_type).to eq('textarea')
    end

    it 'sets the options on a question' do
      filepath = Rails.root.join(fixture_path, 'regular-medication.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'regular-medication')
      described_class.new(filepath: filepath, questions: { 'regular-medication' => question }).call

      expect(question.options).to contain_exactly('Yes', 'No')
    end

    it 'does not set the options on a question if type does not permit it' do
      filepath = Rails.root.join(fixture_path, 'medical-details-information.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-details-information')
      described_class.new(filepath: filepath, questions: { 'medical-details-information' => question }).call

      expect(question.options).to be_empty
    end

    it 'allows followup comments to be set on a question' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      described_class.new(filepath: filepath, questions: { 'medical-professional-referral' => question }).call

      expect(question.followup_comment).to be_truthy
    end

    it 'allows followup comments to be required on an option' do
      filepath = Rails.root.join(fixture_path, 'property-bag-type.yml')
      question = FrameworkQuestion.new(section: 'property-information', key: 'property-bag-type')
      described_class.new(filepath: filepath, questions: { 'property-bag-type' => question }).call

      expect(question.followup_comment_options).to contain_exactly('UK currency')
    end

    it 'allows followup comments to be required on an option if there are no NOMIS mappings' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      described_class.new(filepath: filepath, questions: { 'medical-professional-referral' => question }).call

      expect(question.followup_comment_options).to contain_exactly('Yes')
    end

    it 'sets dependent questions values' do
      filepath = Rails.root.join(fixture_path, 'sensitive-medication.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'sensitive-medication')
      dependent_question = FrameworkQuestion.new(section: 'health', key: 'medication-while-moving')
      questions = {
        'sensitive-medication' => question,
        'medication-while-moving' => dependent_question,
      }

      described_class.new(filepath: filepath, questions: questions).call

      expect(dependent_question.dependent_value).to eq('Yes')
    end

    it 'sets dependent questions parents' do
      filepath = Rails.root.join(fixture_path, 'sensitive-medication.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'sensitive-medication')
      dependent_question = FrameworkQuestion.new(section: 'health', key: 'medication-while-moving')
      questions = {
        'sensitive-medication' => question,
        'medication-while-moving' => dependent_question,
      }

      described_class.new(filepath: filepath, questions: questions).call

      expect(dependent_question.parent).to eq(question)
    end

    it 'adds question to set of questions if it did not exist before' do
      filepath = Rails.root.join(fixture_path, 'sensitive-medication.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'sensitive-medication')
      questions = { 'sensitive-medication' => question }

      updated_questions = described_class.new(filepath: filepath, questions: questions).call
      expect(updated_questions['medication-while-moving']).to be_a(FrameworkQuestion)
    end

    it 'adds dependent question to set of questions if it did not exist before' do
      filepath = Rails.root.join(fixture_path, 'medical-details-information.yml')

      questions = described_class.new(filepath: filepath, questions: {}).call
      expect(questions['medical-details-information']).to be_a(FrameworkQuestion)
    end

    it 'sets flags on question answers' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      questions = { 'medical-professional-referral' => question }
      described_class.new(filepath: filepath, questions: questions).call

      expect(question.framework_flags.size).to eq(2)
    end

    it 'sets attributes on flag as well as question answer to conditionally surface the flag' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      questions = { 'medical-professional-referral' => question }
      described_class.new(filepath: filepath, questions: questions).call

      expect(question.framework_flags.first).to have_attributes(
        flag_type: 'alert',
        title: 'Physical Health',
        question_value: 'Yes',
      )
    end

    it 'sets the prefill value on a question to true if prefill field value set to true' do
      filepath = Rails.root.join(fixture_path, 'regular-medication.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'regular-medication')
      questions = { 'regular-medication' => question }
      described_class.new(filepath: filepath, questions: questions).call

      expect(question).to be_prefill
    end

    it 'sets the prefill value on a question to false if prefill field value set to false' do
      filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
      question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
      questions = { 'medical-professional-referral' => question }
      described_class.new(filepath: filepath, questions: questions).call

      expect(question).not_to be_prefill
    end

    context 'when question type is add_multiple_items' do
      it 'sets a question as required if required validation available' do
        filepath = Rails.root.join(fixture_path, 'property-bags.yml')
        question = FrameworkQuestion.new(section: 'property-information', key: 'property-bags')
        described_class.new(filepath: filepath, questions: { 'property-bags' => question }).call

        expect(question.required).to eq(true)
      end

      it 'does not set dependent questions values' do
        filepath = Rails.root.join(fixture_path, 'property-bags.yml')
        question = FrameworkQuestion.new(section: 'property-information', key: 'property-bags')
        dependent_question = FrameworkQuestion.new(section: 'property-information', key: 'property-bag-type')
        questions = {
          'property-bags' => question,
          'property-bag-type' => dependent_question,
        }
        described_class.new(filepath: filepath, questions: questions).call

        expect(dependent_question.dependent_value).to be_nil
      end

      it 'sets dependent questions parents' do
        filepath = Rails.root.join(fixture_path, 'property-bags.yml')
        question = FrameworkQuestion.new(section: 'property-information', key: 'property-bags')
        dependent_question = FrameworkQuestion.new(section: 'property-information', key: 'property-bag-type')
        questions = {
          'property-bags' => question,
          'property-bag-type' => dependent_question,
        }
        described_class.new(filepath: filepath, questions: questions).call

        expect(dependent_question.parent).to eq(question)
      end

      it 'does not set the prefill value on parent questions' do
        filepath = Rails.root.join(fixture_path, 'property-bags.yml')
        question = FrameworkQuestion.new(section: 'property-information', key: 'property-bags')
        described_class.new(filepath: filepath, questions: { 'property-bags' => question }).call

        expect(question.prefill).to be_nil
      end

      it 'sets prefill value on dependent questions' do
        filepath = Rails.root.join(fixture_path, 'property-bag-type.yml')
        question = FrameworkQuestion.new(section: 'property-information', key: 'property-bag-type')
        questions = {
          'property-bag-type' => question,
        }
        described_class.new(filepath: filepath, questions: questions).call

        expect(question).to be_prefill
      end
    end

    context 'when question has NOMIS mappings' do
      it 'sets NOMIS codes on questions' do
        filepath = Rails.root.join(fixture_path, 'wheelchair-users.yml')
        question = FrameworkQuestion.new(section: 'health', key: 'wheelchair-users')
        questions = { 'wheelchair-users' => question }
        described_class.new(filepath: filepath, questions: questions).call

        expect(question.framework_nomis_codes.size).to eq(2)
      end

      it 'sets correct attributes on NOMIS codes' do
        filepath = Rails.root.join(fixture_path, 'wheelchair-users.yml')
        question = FrameworkQuestion.new(section: 'health', key: 'wheelchair-users')
        questions = { 'wheelchair-users' => question }
        described_class.new(filepath: filepath, questions: questions).call

        expect(question.framework_nomis_codes.first).to have_attributes(
          code: 'PEEP',
          code_type: 'personal_care_need',
          fallback: false,
        )
      end

      it 'sets NOMIS fallback codes on questions' do
        filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
        question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
        questions = { 'medical-professional-referral' => question }
        described_class.new(filepath: filepath, questions: questions).call

        expect(question.framework_nomis_codes.size).to eq(2)
      end

      it 'sets correct attributes on NOMIS fallback codes' do
        filepath = Rails.root.join(fixture_path, 'medical-professional-referral.yml')
        question = FrameworkQuestion.new(section: 'health', key: 'medical-professional-referral')
        questions = { 'medical-professional-referral' => question }
        described_class.new(filepath: filepath, questions: questions).call

        expect(question.framework_nomis_codes.first).to have_attributes(
          code: nil,
          code_type: 'alert',
          fallback: true,
        )
      end
    end
  end
end
