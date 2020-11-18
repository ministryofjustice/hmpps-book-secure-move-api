# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Frameworks::Manifest do
  describe '#call' do
    let(:framework_path) { 'spec/fixtures/files/frameworks' }

    it 'returns a list of question keys mapped to questions' do
      filepath = Rails.root.join(framework_path, 'person-escort-record/manifests/health-information.yml')
      questions = described_class.new(filepath: filepath).call
      expect(questions.keys).to contain_exactly(
        'sensitive-medication',
        'regular-medication',
        'medical-professional-referral',
        'medical-details-information',
      )
    end

    it 'sets the framework question section and key' do
      filepath = Rails.root.join(
        framework_path,
        'youth-risk-assessment/manifests/offence-details.yml',
      )

      questions = described_class.new(filepath: filepath).call
      expect(questions.values.first).to have_attributes(
        'section' => 'offence-details',
        'key' => 'wheelchair-user',
      )
    end

    it 'attaches question dependency to correct dependent value' do
      filepath = Rails.root.join(
        framework_path,
        'person-escort-record/manifests/health-information.yml',
      )

      questions = described_class.new(filepath: filepath).call

      expect(questions['medical-details-information']).to have_attributes(
        'section' => 'health-information',
        'dependent_value' => 'Yes',
      )
    end

    it 'marks all questions in a section as dependent if section is dependent on another question' do
      filepath = Rails.root.join(
        framework_path,
        'person-escort-record/manifests/health-information.yml',
      )

      questions = described_class.new(filepath: filepath).call

      expect(questions['medical-details-information'].parent.key).to eq('regular-medication')
    end
  end
end
