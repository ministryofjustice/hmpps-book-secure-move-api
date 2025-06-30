require 'rails_helper'

RSpec.describe GenericEvent::LodgingCancel do
  subject(:generic_event) { build(:event_lodging_cancel, details:) }

  let(:details) do
    {
      start_date:,
      end_date:,
      described_class::LOCATION_ATTRIBUTE_KEY => create(:location).id,
    }
  end
  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-02' }

  it_behaves_like 'an event with details', :start_date, :end_date, :cancellation_reason, :cancellation_reason_comment
  it_behaves_like 'an event with relationships', described_class::LOCATION_ATTRIBUTE_KEY => :locations
  it_behaves_like 'an event with eventable types', 'Lodging'
  it_behaves_like 'an event requiring a location', described_class::LOCATION_ATTRIBUTE_KEY
  it_behaves_like 'an event with a location in the feed', described_class::LOCATION_ATTRIBUTE_KEY

  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }

  it { is_expected.to validate_inclusion_of(:cancellation_reason).in_array(Lodging::CANCELLATION_REASONS) }

  context 'when the start_date format is not an iso8601 date' do
    let(:start_date) { '2023/01/01' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date format is not an iso8601 date' do
    let(:end_date) { '2023/01/02' }

    it { is_expected.to be_invalid }
  end

  describe 'cancellation reasons' do
    describe 'backward compatibility' do
      let(:legacy_lodging_reasons) do
        %w[
          made_in_error
          supplier_declined_to_move
          cancelled_by_pmu
          other
        ]
      end

      it 'includes all legacy lodging cancellation reasons' do
        legacy_lodging_reasons.each do |reason|
          expect(Lodging::CANCELLATION_REASONS).to include(reason),
                                                   "Legacy lodging reason '#{reason}' is missing from Lodging::CANCELLATION_REASONS. " \
                                                   'This could break GenericEvent::LodgingCancel validation and API clients.'
        end
      end
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_lodging_cancel, details:) }

    context 'when the cancellation_reason_comment is present' do
      let(:details) do
        {
          start_date:,
          end_date:,
          described_class::LOCATION_ATTRIBUTE_KEY => create(:location).id,
          cancellation_reason: 'made_in_error',
          cancellation_reason_comment: 'It was a mistake',
        }
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'LodgingCancel',
          'notes' => 'Flibble',
          'created_by' => 'TEST_USER',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Lodging',
          'details' => generic_event.details,
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end

    context 'when the cancellation_reason_comment is not present' do
      let(:details) do
        {
          start_date:,
          end_date:,
          described_class::LOCATION_ATTRIBUTE_KEY => create(:location).id,
          cancellation_reason: 'made_in_error',
        }
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'LodgingCancel',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Lodging',
          'details' => {
            'cancellation_reason' => 'made_in_error',
            'cancellation_reason_comment' => '',
          },
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end
  end
end
