# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:person_escort_record) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
end
