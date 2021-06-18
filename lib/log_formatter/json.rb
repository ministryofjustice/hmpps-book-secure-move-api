require 'json'

module LogFormatter
  class Json
    def call(severity, timestamp, progname, msg)
      data = {}
      data[:severity] = severity if severity
      data[:timestamp] = timestamp if timestamp
      data[:progname] = progname if progname

      # Handle messages coming from lograge and other json preformatted log messages
      begin
        msg = JSON.parse(msg)
        data.merge!(msg)
      rescue JSON::ParserError
        data[:msg] = msg
      end

      "#{::JSON.dump(data)}\n"
    end
  end
end
