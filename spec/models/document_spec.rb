# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  it { is_expected.to validate_presence_of(:document_type) }
  it { is_expected.to validate_presence_of(:file) }
end
