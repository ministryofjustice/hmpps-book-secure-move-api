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

  def record_failure(record)
    failures.append(record)
  end

  def save(obj, record)
    if obj.save
      record_success(record)
    else
      record_failure(record)
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
