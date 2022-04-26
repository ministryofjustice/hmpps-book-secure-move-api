require 'rails_helper'

RSpec.describe GenericEvent::PerMedicalMedication do
  subject(:generic_event) { build(:event_per_medical_medication) }

  it_behaves_like 'an event about a medical'
end
