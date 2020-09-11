class EventCopier
  def initialize(dry_run:)
    @dry_run = dry_run
    @results = {
      validation_failure_count: 0,
      name_error_count: 0,
      success_count: 0,
      validation_errors: [],
      name_errors: Set.new,
      dry_run: dry_run,
    }
  end

  def call
    Event.not_copied.find_each do |event|
      generic_event = GenericEvent.from_event(event)

      if @dry_run
        if generic_event.valid?
          @results[:success_count] += 1
        else
          @results[:validation_errors] << {
            'id' => event.id,
            'errors' => generic_event.errors.messages,
          }

          @results[:validation_failure_count] += 1
        end
      else
        if generic_event.save
          event.update(generic_event_id: generic_event.id)

          @results[:success_count] += 1
        else
          @results[:validation_errors] << {
            'id' => event.id,
            'errors' => generic_event.errors.messages,
          }

          @results[:validation_failure_count] += 1
        end
      end
    rescue NameError => e
      missing_event = e.message.split('::').last

      @results[:name_error_count] += 1
      @results[:name_errors] << missing_event
    end

    @results
  end
end
