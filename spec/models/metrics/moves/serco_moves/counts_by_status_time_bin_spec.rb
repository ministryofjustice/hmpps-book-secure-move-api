# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::SercoMoves::CountsByStatusTimeBin do
  it 'includes the SercoMoves module' do
    expect(described_class.ancestors).to include(Metrics::Moves::SercoMoves)
  end
end
