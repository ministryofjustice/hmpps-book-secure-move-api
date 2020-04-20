# frozen_string_literal: true

RSpec.configure do |config|
  def load_schema(file_name)
    return unless File.file?("#{Rails.root}/swagger/v1/#{file_name}")

    schema = load_json_schema(file_name)
    JSON::Validator.add_schema(JSON::Schema.new(schema, file_name))
  end

  def load_json_schema(file_name)
    File.open("#{Rails.root}/swagger/v1/#{file_name}") do |file|
      JSON.parse(file.read)
    end
  end

  config.before(:suite) do
    # This runs *once* before the test suite starts to ensure that we can resolve all of the Swagger JSON definitions
    Dir.glob('**/*.json', base: 'swagger/v1').each { |file_name| load_schema(file_name) }
  end
end
