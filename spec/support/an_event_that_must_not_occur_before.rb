# frozen_string_literal: true

RSpec.shared_examples 'an event that must not occur before' do |type|
  context type do
    describe '.save' do
      before do
        Timecop.freeze('2021-01-01 00:00:00')
      end

      context "when a #{type} event occurs before a #{described_class} event" do
        before do
          type.constantize.create!(
            occurred_at: Time.zone.local(2020, 12, 1),
            recorded_at: Time.zone.now,
            eventable: generic_event.eventable,
          )
        end

        it 'saves' do
          expect(generic_event.save).to eq(true)
        end
      end

      context "when a #{type} event occurs after a #{described_class} event" do
        before do
          type.constantize.create!(
            occurred_at: Time.zone.local(2021, 1, 2),
            recorded_at: Time.zone.now,
            eventable: generic_event.eventable,
          )
        end

        it 'adds an error to errors' do
          expect(generic_event.save).to eq(false)
          expect(generic_event.errors.errors.to_s).to include("#{described_class} may not occur before #{type}")
        end
      end

      context "when a #{type} event does not occur" do
        it 'saves' do
          expect(generic_event.save).to eq(true)
        end
      end
    end
  end
end
