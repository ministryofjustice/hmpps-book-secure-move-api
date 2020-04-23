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
    end

    def json_api_error
      {
          code: code,
          status: status,
          title: title,
          details: details,
      }
    end
  end
end
