require 'rails_helper'

RSpec.describe GenericEvent::LodgingUpdate do
  it_behaves_like 'an event with eventable types', 'Lodging'
end
