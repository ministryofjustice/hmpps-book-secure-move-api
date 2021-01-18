# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::GeoameyMoves::CountsByStatus do
  it 'includes the GeoameyMoves module' do
    expect(described_class.ancestors).to include(Metrics::Moves::GeoameyMoves)
  end
end
