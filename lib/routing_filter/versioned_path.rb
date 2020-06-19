# TODO: Remove this when v1 is dead
module RoutingFilter
  class VersionedPath < Filter
    def around_recognize(path, _env)
      remove_version!(path) unless path.include?('swagger')

      yield
    end

    def around_generate(_params)
      yield.tap do |result|
        add_version!(result)
      end
    end

  private

    def remove_version!(path)
      path.gsub!('/v1', '')
    end

    def add_version!(result)
      path, _options = result

      path.gsub!('/api/', '/api/v1/')
    end
  end
end
