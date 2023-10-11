# frozen_string_literal: true

RSpec.configure do |_config|
  def validate_response(response, schema: nil, version: 'v2', strict: true, status: 200)
    # NB: there is no point validating the schema of the json response unless the status matches the expectation: an
    # error response will never validate against a success schema and the schema errors will confuse the issue.

    if status.between?(200, 299) && response.successful? || status >= 300 && !response.successful?
      # The API returned an expected status: now validate the status code and the response body (against the schema if appropriate)
      expect(response.status).to eql(status) # NB validate status before schema (otherwise the fragment won't exist)

      if response.status == 204
        # 204 no content cannot validate against a schema; instead just check it is blank
        expect(response.body).to be_blank
        nil
      else
        # NB: we get more helpful error messages by calling fully_validate and checking for an empty array
        raise 'Please specify a schema' if schema.blank?

        schema_file = load_yaml_schema(schema, version:)
        json_body = JSON.parse(response.body)
        expect(JSON::Validator.fully_validate(schema_file, json_body, strict:, fragment: "#/#{status}")).to be_empty
        json_body
      end
    else
      # The API returned an unexpected status (e.g. an error when success was expected, or success when an error was expected)
      # To facilitate test debugging, fail with the response details
      raise "Unexpected API response (expected: #{status}, received: #{response.status}):\n\n#{response.body}"
    end
  end
end
