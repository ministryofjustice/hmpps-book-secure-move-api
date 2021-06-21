# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe PopulationSerializer do
  subject(:serializer) { described_class.new(population, adapter_options) }

  let(:population) { create(:population) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  context 'with no options' do
    let(:adapter_options) { {} }

    it 'contains a type property' do
      expect(result_data[:type]).to eql 'populations'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql population.id
    end

    it 'contains a date attribute' do
      expect(attributes[:date]).to eql population.date.iso8601
    end

    it 'contains an operational capacity' do
      expect(attributes[:operational_capacity]).to eql population.operational_capacity
    end

    it 'contains a usable capacity attribute' do
      expect(attributes[:usable_capacity]).to eql population.usable_capacity
    end

    it 'contains an unlock attribute' do
      expect(attributes[:unlock]).to eql population.unlock
    end

    it 'contains a bedwatch attribute' do
      expect(attributes[:bedwatch]).to eql population.bedwatch
    end

    it 'contains an overnights in attribute' do
      expect(attributes[:overnights_in]).to eql population.overnights_in
    end

    it 'contains an overnights out attribute' do
      expect(attributes[:overnights_out]).to eql population.overnights_out
    end

    it 'contains an out of area courts attribute' do
      expect(attributes[:out_of_area_courts]).to eql population.out_of_area_courts
    end

    it 'contains a discharges attribute' do
      expect(attributes[:discharges]).to eql population.discharges
    end

    it 'contains a free spaces attribute' do
      expect(attributes[:free_spaces]).to eql population.free_spaces
    end

    it 'contains an updated by attribute' do
      expect(attributes[:updated_by]).to eql population.updated_by
    end

    it 'contains a created_at attribute' do
      expect(attributes[:created_at]).to eql population.created_at.iso8601
    end

    it 'contains an updated_at attribute' do
      expect(attributes[:updated_at]).to eql population.updated_at.iso8601
    end
  end

  describe 'location' do
    let(:adapter_options) do
      {
        include: %i[location],
      }
    end
    let(:expected_json) do
      [
        {
          id: population.location.id,
          type: 'locations',
          attributes: { location_type: 'prison', title: population.location.title },
        },
      ]
    end

    it 'contains an included location' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'moves_from' do
    let(:adapter_options) do
      { include: PopulationSerializer::SUPPORTED_RELATIONSHIPS }
    end
    let(:population) { create(:population, :with_moves_from) }
    let(:move) { population.moves_from.first }

    it 'contains a moves_from relationship' do
      expect(result_data[:relationships][:moves_from][:data]).to contain_exactly(id: move.id, type: 'moves')
    end

    it 'contains an included move' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[moves locations])
    end
  end

  describe 'moves_to' do
    let(:adapter_options) do
      { include: PopulationSerializer::SUPPORTED_RELATIONSHIPS }
    end
    let(:population) { create(:population, :with_moves_to) }
    let(:move) { population.moves_to.first }

    it 'contains a moves_to relationship' do
      expect(result_data[:relationships][:moves_to][:data]).to contain_exactly(id: move.id, type: 'moves')
    end

    it 'contains an included move' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[moves locations])
    end
  end

  context 'without moves_from' do
    let(:adapter_options) { { include: PopulationSerializer::SUPPORTED_RELATIONSHIPS } }

    it 'contains empty moves_from' do
      expect(result_data[:relationships][:moves_from][:data]).to be_empty
    end

    it 'does not contain an included move' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations])
    end
  end

  context 'without moves_to' do
    let(:adapter_options) { { include: PopulationSerializer::SUPPORTED_RELATIONSHIPS } }

    it 'contains empty moves_to' do
      expect(result_data[:relationships][:moves_to][:data]).to be_empty
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
