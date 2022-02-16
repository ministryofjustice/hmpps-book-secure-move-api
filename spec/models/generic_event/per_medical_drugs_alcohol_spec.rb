require 'rails_helper'

RSpec.describe GenericEvent::PerMedicalDrugsAlcohol do
  subject(:generic_event) { build(:event_per_medical_drugs_alcohol) }

  it_behaves_like 'an event about a medical'
end
