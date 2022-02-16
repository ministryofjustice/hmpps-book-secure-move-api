require 'rails_helper'

RSpec.describe GenericEvent, type: :model do
  subject(:generic_event) { build(:event_move_cancel) }

  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to belong_to(:supplier).optional }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:occurred_at) }
  it { is_expected.to validate_presence_of(:recorded_at) }

  it { expect(described_class).to respond_to(:applied_order) }

  it 'updates the parent record when updated' do
    eventable = create(:move)
    event = create(:event_move_cancel, eventable: eventable)

    expect { event.update(occurred_at: event.occurred_at + 1.day) }.to(change { eventable.reload.updated_at })
  end

  it 'updates the parent record when created' do
    eventable = create(:move)

    expect { create(:event_move_cancel, eventable: eventable) }.to(change { eventable.reload.updated_at })
  end

  it 'defines the correct STI classes for validation' do
    expected_sti_classes = Dir['app/models/generic_event/*'].map { |file|
      file
        .sub('app/models/generic_event/', '')
        .sub('.rb', '')
        .camelcase
    } - %w[Incident Medical Notification]

    expect(described_class::STI_CLASSES).to match_array(expected_sti_classes)
  end

  describe '#event_type' do
    it 'returns nil when type is missing' do
      event = described_class.new

      expect(event.event_type).to be_nil
    end
  end

  describe '#event_classification' do
    it 'returns :default' do
      event = described_class.new

      expect(event.event_classification).to eq :default
    end

    it 'is automatically assigned on creation' do
      event = create(:event_move_cancel, classification: nil)

      expect(event.classification).to eq 'default'
    end
  end

  describe '#trigger' do
    subject(:generic_event) { create(:event_move_cancel) }

    it 'does nothing to the eventable attributes by default' do
      expect { generic_event.trigger }.not_to(change { generic_event.reload.eventable.attributes })
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_cancel, supplier: create(:supplier, key: 'serco')) }

    it 'returns the expected attributes' do
      expected_attributes = {
        'id' => generic_event.id,
        'type' => 'MoveCancel',
        'notes' => 'Flibble',
        'created_by' => 'TEST_USER',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Move',
        'details' => { 'cancellation_reason' => 'made_in_error', 'cancellation_reason_comment' => 'It was a mistake' },
        'supplier' => 'serco',
      }

      expect(generic_event.for_feed).to include_json(expected_attributes)
    end
  end

  describe '.updated_at_range scope' do
    let(:updated_at_from) { Time.zone.yesterday.beginning_of_day }
    let(:updated_at_to) { Time.zone.yesterday.end_of_day }

    it 'returns the expected events' do
      create(:event_move_cancel, updated_at: updated_at_from - 1.second)
      create(:event_move_accept, updated_at: updated_at_to + 1.second)
      on_start_event = create(:event_move_approve, updated_at: updated_at_from)
      on_end_event = create(:event_move_start, updated_at: updated_at_to)

      actual_events = described_class.updated_at_range(updated_at_from, updated_at_to)

      expect(actual_events).to match_array([on_start_event, on_end_event])
    end
  end

  describe '.created_at_range scope' do
    let(:created_at_from) { Time.zone.yesterday.beginning_of_day }
    let(:created_at_to) { Time.zone.yesterday.end_of_day }

    it 'returns the expected events' do
      create(:event_move_cancel, created_at: created_at_from - 1.second)
      create(:event_move_accept, created_at: created_at_to + 1.second)
      on_start_event = create(:event_move_approve, created_at: created_at_from)
      on_end_event = create(:event_move_start, created_at: created_at_to)

      actual_events = described_class.created_at_range(created_at_from, created_at_to)

      expect(actual_events).to match_array([on_start_event, on_end_event])
    end
  end

  describe '.serializer' do
    let(:relation_serializer) { event.class.serializer.relationships_to_serialize[relation_serializer_key].serializer }

    context 'when the event STI defines relationships' do
      context 'with no supported V2 version' do
        let(:event) do
          create(
            :event_move_lockout,
            details: {
              from_location_id: create(:location).id,
              reason: 'no_space',
              authorised_at: Time.zone.now.iso8601,
              authorised_by: 'PMU',
            },
          )
        end

        let(:relation_serializer_key) { :from_location }

        it 'falls back to the non-V2 version of the relation serializer' do
          expect(relation_serializer).to eq(LocationSerializer)
        end
      end

      context 'with a supported V2 version' do
        let(:event) do
          create(:event_move_cross_supplier_pick_up, :with_move_reference)
        end

        let(:relation_serializer_key) { :previous_move }

        it 'uses the V2 version of the relation serializer' do
          expect(relation_serializer).to eq(V2::MoveSerializer)
        end
      end
    end

    context 'when the event STI does not define relationships' do
      let(:event) { create(:event_per_generic, details: {}) }

      it 'defaults to the GenericEventSerializer' do
        expect(event.class.serializer).to eq(GenericEventSerializer)
      end
    end
  end
end
