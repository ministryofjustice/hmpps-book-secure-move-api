RSpec.shared_examples 'an event requiring a location' do |location_key|
  it "validates #{location_key} existing in the database" do
    generic_event.public_send("#{location_key}=", 'flibble')
    expect { generic_event.valid? }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Location with 'id'=.*flibble/)
  end
end
