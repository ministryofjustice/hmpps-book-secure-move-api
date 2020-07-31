# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::MoveTypeValidator do
  subject(:target) do
    # anonymous class to test validation against
    Class.new {
      include ActiveModel::Validations
      attr_accessor :from_location, :to_location, :move_type
      validates_with Moves::MoveTypeValidator

      def self.name
        'TestValidationClass'
      end
    }.new
  end

  before { target.move_type = move_type }

  context 'when valid' do
    let(:move_type) { nil }

    it { is_expected.to be_valid }
  end

  context 'with court_other `move_type`' do
    let(:move_type) { 'court_other' }

    it 'validates `to_location` is not a prison, sch or stc' do
      target.to_location = build(:location, :court)
      expect(target).to be_valid
    end

    it 'validates `to_location` is not nil' do
      target.to_location = nil
      expect(target).not_to be_valid
    end

    it 'has an error if `to_location` is not a prison, sch or stc' do
      %i[prison stc stc].each do |location_type|
        target.to_location = build(:location, location_type)
        expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
        expect(target.errors[:to_location]).to match_array('must not be a prison, secure training centre or secure childrens hospital for court other move')
      end
    end
  end

  context 'with hospital `move_type`' do
    let(:move_type) { 'hospital' }

    it 'validates `to_location` is a high_security_hospital' do
      target.to_location = build(:location, :hospital)
      expect(target).to be_valid
    end

    it 'validates `to_location` is not nil' do
      target.to_location = nil
      expect(target).not_to be_valid
    end

    it 'has an error if `to_location` is not a high security hospital' do
      target.to_location = build(:location, :court)
      expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
      expect(target.errors[:to_location]).to match_array('must be a high security hospital location for hospital move')
    end
  end

  context 'with prison_remand `move_type`' do
    let(:move_type) { 'prison_remand' }

    it 'validates `to_location` is a prison, sch or stc' do
      %i[prison stc stc].each do |location_type|
        target.to_location = build(:location, location_type)
        expect(target).to be_valid
      end
    end

    it 'validates `to_location` is not nil' do
      target.to_location = nil
      expect(target).not_to be_valid
    end

    it 'has an error if `to_location` is not a prison, sch or stc' do
      target.from_location = build(:location, :court)
      expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
      expect(target.errors[:to_location]).to match_array('must be a prison, secure training centre or secure childrens hospital for prison remand move')
    end
  end

  context 'with video remand hearing `move_type`' do
    let(:move_type) { 'video_remand' }

    it 'validates `from_location` is a police location' do
      target.from_location = build(:location, :police)
      expect(target).to be_valid
    end

    it 'validates `from_location` is not nil' do
      target.from_location = nil
      expect(target).not_to be_valid
    end

    it 'has an error if `from_location` is not a police location' do
      target.from_location = build(:location, :court)
      expect(target).not_to be_valid # NB: need to check for validity before reading the error messages
      expect(target.errors[:from_location]).to match_array('must be a police location for video remand move')
    end
  end
end
