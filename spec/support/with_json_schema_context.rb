# frozen_string_literal: true

RSpec.shared_context 'with json schema', shared_context: :metadata do
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

  before(:all) do
    Dir.glob('**/*.json', base: 'swagger/v1').each { |file_name| load_schema(file_name) }
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    config.include_context 'with json schema'
  end
end
