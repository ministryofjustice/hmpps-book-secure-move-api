require 'rails_helper'

RSpec.describe GenericEvent::LodgingUpdate do
  subject(:generic_event) { build(:event_lodging_update, :all) }

  it_behaves_like 'an event with details', :old_start_date, :start_date, :old_end_date, :end_date
  it_behaves_like 'an event with relationships', old_location_id: :locations, location_id: :locations
  it_behaves_like 'a lodging event'
  it_behaves_like 'an event with a location in the feed', :old_location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  context 'when all properties are missing' do
    subject(:generic_event) { build(:event_lodging_update) }

    it { is_expected.to be_invalid }
  end

  context 'when start_date is specified' do
    subject(:generic_event) { build(:event_lodging_update, :start_date) }

    it { is_expected.to be_valid }

    context 'when old_start_date is missing' do
      before do
        generic_event.details.delete(:old_start_date)
      end

      it { is_expected.to be_invalid }
    end

    context 'when start_date is not a date' do
      before do
        generic_event.details[:start_date] = 'not a date'
      end

      it { is_expected.to be_invalid }
    end

    context 'when old_start_date is not a date' do
      before do
        generic_event.details[:old_start_date] = 'not a date'
      end

      it { is_expected.to be_invalid }
    end
  end

  context 'when end_date is specified' do
    subject(:generic_event) { build(:event_lodging_update, :end_date) }

    it { is_expected.to be_valid }

    context 'when old_end_date is missing' do
      before do
        generic_event.details.delete(:old_end_date)
      end

      it { is_expected.to be_invalid }
    end

    context 'when end_date is not a date' do
      before do
        generic_event.details[:end_date] = 'not a date'
      end

      it { is_expected.to be_invalid }
    end

    context 'when old_end_date is not a date' do
      before do
        generic_event.details[:old_end_date] = 'not a date'
      end

      it { is_expected.to be_invalid }
    end
  end

  context 'when location_id is specified' do
    subject(:generic_event) { build(:event_lodging_update, :location_id) }

    it { is_expected.to be_valid }

    context 'when old_location_id is missing' do
      before do
        generic_event.details.delete(:old_location_id)
      end

      it { is_expected.to be_invalid }
    end
  end
end
