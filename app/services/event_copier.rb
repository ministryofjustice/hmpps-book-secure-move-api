class EventCopier
  def initialize
    @results = {
      failure_count: 0,
      success_count: 0,
      errors: [],
    }
  end

  def call
    Event.not_copied.find_each do |event|
      generic_event = GenericEvent.from_event(event)

      if generic_event.save
        event.update(generic_event: generic_event)

        @results[:success_count] += 1
      else
        @results[:errors] << {
          'id' => event.id,
          'errors' => event.errors.messages,
        }

        @results[:failure_count] += 1
      end
    end

    @results
  end
end
