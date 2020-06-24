# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency::ConflictError do
  it { expect(described_class).to be < StandardError }
end
