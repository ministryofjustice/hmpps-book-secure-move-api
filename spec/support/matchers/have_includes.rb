RSpec::Matchers.define :have_includes do |*includes|
  match do |response_json|
    ids = response_json.fetch('included', []).map do |included|
      included.fetch('id', nil)
    end

    includes.flatten!

    includes.all? { |i| ids.include?(i.id) }
  end

  diffable
end
