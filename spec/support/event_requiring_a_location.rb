RSpec.shared_examples 'an event requiring a location' do |location_key|
  it "validates #{location_key} presence" do
    expect(generic_event).to validate_presence_of(location_key)
  end

  context "when the #{location_key} does not exist" do
    let(:named_location) { location_key.to_s.sub('_id', '') }

    before do
      generic_event.public_send("#{location_key}=", 'flibble')
    end

    it { is_expected.not_to be_valid }

    it 'attaches a custom message to the generic event' do
      expect { generic_event.valid? }
        .to change { generic_event.errors[location_key] }
        .from([])
        .to(["The location relationship you passed has an id that does not exist in our system. Please use an existing #{named_location}"])
    end
  end

  it "validates #{location_key} existing in the database" do
    generic_event.public_send("#{location_key}=", 'flibble')

    expect(generic_event).not_to be_valid
  end
end
