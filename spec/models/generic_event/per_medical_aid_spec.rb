require 'rails_helper'

RSpec.describe GenericEvent::PerMedicalAid do
  subject(:generic_event) { build(:event_per_medical_aid) }

  it_behaves_like 'an event about a medical'
end
