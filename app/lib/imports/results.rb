class Imports::Results
  def initialize
    @successes = []
    @failures = []
  end

  attr_reader :successes, :failures

  def total
    @total ||= successes.count + failures.count
  end

  def record_success(record)
    successes.append(record)
  end

  def record_failure(record, reason:)
    failures.append(record.merge(reason: reason))
  end

  def save(obj, record)
    if obj.save
      record_success(record)
      true
    else
      record_failure(record, reason: 'Could not save record.')
      false
    end
  end

  def summary
    string = "Imported #{total} records with #{failures.count} failures.\n"

    unless failures.empty?
      string += "\n"
      string += CSV.generate(headers: failures.first.keys, write_headers: true) do |csv|
        failures.each { |failure| csv << failure }
      end
    end

    string
  end
end
