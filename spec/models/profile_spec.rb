# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to belong_to(:ethnicity).optional }
  it { is_expected.to belong_to(:gender).optional }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }
end
