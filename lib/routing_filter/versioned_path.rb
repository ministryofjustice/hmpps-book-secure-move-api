# TODO: Remove this when v1 is dead
module RoutingFilter
  class VersionedPath < Filter
    def around_recognize(path, _env)
      remove_version!(path) unless path.start_with?('/api-docs/')

      yield
    end

    def around_generate(_params)
      yield
    end

  private

    def remove_version!(path)
      path.gsub!('/v1', '')
    end
  end
end
