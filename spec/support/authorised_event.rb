RSpec.shared_examples 'an authorised event' do
  let(:authorised_bies) do
    %w[
      PMU
      CDM
      Other
    ]
  end

  # TODO: Reinstate this validation when suppliers have moved over to generic event api
  # it { is_expected.to validate_presence_of(:authorised_by) }
  it { is_expected.to validate_inclusion_of(:authorised_by).in_array(authorised_bies) }

  context 'when authorised_at is supplied' do
    it 'is valid when the authorised_at value is a valid iso8601 datetime' do
      generic_event.authorised_at = '2020-06-16T10:20:30+01:00'
      expect(generic_event).to be_valid
    end

    it 'is invalid when the authorised_at value is not a valid iso8601 datetime' do
      generic_event.authorised_at = '16-06-2020 10:20:30+01:00'
      expect(generic_event).not_to be_valid
    end
  end
end
