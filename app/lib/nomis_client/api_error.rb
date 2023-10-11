module NomisClient
  class ApiError
    # This is a simple PORO build to serialize generic Nomis errors.
    # This is used in place of the AMS error serializer, since there is not an AR Model linked to this error.

    attr_reader :code, :status, :title, :details

    def initialize(status:, error_body:)
      @status = status
      @code = 'NOMIS-ERROR'

      nomis_error = JSON.parse(error_body)

      @title = nomis_error['userMessage'].to_s
      @details = "#{nomis_error['developerMessage']} #{nomis_error['moreInfo']}".strip
    rescue JSON::ParserError
      @title = 'Unparseable error from Nomis'
      @details = "Status #{status}. We tried to parse an error from Nomis and failed. Is the Elite2API routeable?"
    end

    def json_api_error
      {
        code:,
        status:,
        title:,
        details:,
      }
    end
  end
end
