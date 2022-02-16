require 'rails_helper'

RSpec.describe GenericEvent::PerMedicalMentalHealth do
  subject(:generic_event) { build(:event_per_medical_mental_health) }

  it_behaves_like 'an event about a medical'
end
