RSpec::Matchers.define :have_includes do |*includes|
  attr_reader :actual, :expected

  match do |response_json|
    @actual = response_json.fetch('included', []).map do |included|
      [included['id'], included['type']]
    end

    @expected = includes.flatten
    @expected = @expected.map do |entity|
      id = entity.id
      type = entity.class&.to_s&.pluralize&.tableize

      [id, type]
    end

    expect(@expected).to match_array(@actual)
  end

  def failure_message
    missing_in_actual = expected - actual
    missing_in_expected = actual - expected

    message = ''
    message += "Missing in actual: #{missing_in_actual}" if missing_in_actual.any?
    message += "Missing in expected: #{missing_in_expected}" if missing_in_expected.any?
  end

  diffable
end
