require 'rails_helper'

RSpec.describe PersonnelNumberValidation do
  subject(:instance) { validatable.new }

  context 'without fields' do
    let(:validatable) { Class.new(Validatable) }

    it { is_expected.to be_valid }
  end

  context 'with supplier_personnel_number' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :supplier_personnel_number }
    end

    context "and the field isn't set" do
      it { is_expected.not_to be_valid }
    end

    context 'and the field is set' do
      before { instance.supplier_personnel_number = '123' }

      it { is_expected.to be_valid }
    end
  end

  context 'with police_personnel_number' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :police_personnel_number }
    end

    context "and the field isn't set" do
      it { is_expected.not_to be_valid }
    end

    context 'and the field is set' do
      before { instance.police_personnel_number = '123' }

      it { is_expected.to be_valid }
    end
  end

  context 'with supplier_personnel_number and police_personnel_number' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :supplier_personnel_number, :police_personnel_number }
    end

    context 'and none of the fields are set' do
      it { is_expected.not_to be_valid }
    end

    context 'and the supplier field is set' do
      before { instance.supplier_personnel_number = '123' }

      it { is_expected.to be_valid }
    end

    context 'and the police field is set' do
      before { instance.police_personnel_number = '123' }

      it { is_expected.to be_valid }
    end

    context 'and both fields are set' do
      before do
        instance.supplier_personnel_number = '123'
        instance.police_personnel_number = '123'
      end

      it { is_expected.not_to be_valid }
    end
  end

  context 'with supplier_personnel_numbers' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :supplier_personnel_numbers }
    end

    context "and the field isn't set" do
      it { is_expected.not_to be_valid }
    end

    context 'and the field is set' do
      before { instance.supplier_personnel_numbers = %w[123 456] }

      it { is_expected.to be_valid }
    end
  end

  context 'with police_personnel_numbers' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :police_personnel_numbers }
    end

    context "and the field isn't set" do
      it { is_expected.not_to be_valid }
    end

    context 'and the field is set' do
      before { instance.police_personnel_numbers = %w[123 456] }

      it { is_expected.to be_valid }
    end
  end

  context 'with supplier_personnel_numbers and police_personnel_numbers' do
    let(:validatable) do
      Class.new(Validatable) { attr_accessor :supplier_personnel_numbers, :police_personnel_numbers }
    end

    context 'and none of the fields are set' do
      it { is_expected.not_to be_valid }
    end

    context 'and the supplier field is set' do
      before { instance.supplier_personnel_numbers = %w[123 456] }

      it { is_expected.to be_valid }
    end

    context 'and the police field is set' do
      before { instance.police_personnel_numbers = %w[123 456] }

      it { is_expected.to be_valid }
    end

    context 'and both fields are set' do
      before do
        instance.supplier_personnel_numbers = %w[123 456]
        instance.police_personnel_numbers = %w[123 456]
      end

      it { is_expected.not_to be_valid }
    end
  end
end

class Validatable
  include ActiveModel::Validations
  validates_with PersonnelNumberValidation
end
