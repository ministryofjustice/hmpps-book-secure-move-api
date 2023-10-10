# frozen_string_literal: true

RSpec.configure do |config|
  def load_schema(file_name, version: 'v1')
    return unless File.file?("#{Rails.root}/swagger/#{version}/#{file_name}")

    schema = load_yaml_schema(file_name, version:)

    # TODO: when moving to fully support v1 and v2 stop loading v1 twice
    JSON::Validator.add_schema(JSON::Schema.new(schema, file_name)) if version == 'v1'
    JSON::Validator.add_schema(JSON::Schema.new(schema, [version, file_name].join('/')))
  end

  def load_yaml_schema(file_name, version: 'v1')
    File.open("#{Rails.root}/swagger/#{version}/#{file_name}") do |file|
      YAML.safe_load(file.read)
    rescue Psych::SyntaxError => e
      # Include original filename in exception to make debugging a less cryptic affair
      raise Psych::SyntaxError.new(file_name, e.line, e.column, e.offset, e.problem, e.context)
    end
  end

  config.before(:suite) do
    # This runs *once* before the test suite starts to ensure that we can resolve all of the Swagger definitions
    Dir.glob('**/*.yaml', base: 'swagger/v1').each { |file_name| load_schema(file_name) }
    Dir.glob('**/*.yaml', base: 'swagger/v2').each { |file_name| load_schema(file_name, version: 'v2') }
  end
end
