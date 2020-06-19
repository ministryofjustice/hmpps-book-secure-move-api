# TODO: Remove this when v1 is dead
module RoutingFilter
  class VersionedPath < Filter
    HEADER_VERSION_REGEX = %r{.*version=(?<version>\d+)}.freeze
    PATH_VERSION_REGEX = %r{\A\/api(\/(?<version>v1))\/.+\Z}.freeze

    def around_recognize(path, env)
      remove_version!(path)

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

    def raise_not_found_error?(path, env)
      path_version = path_version(path)
      header_version = header_version(env.headers['Accept'])

      true if path_version == 'v1' && header_version == '2'
    end

    def path_version(path)
      match = path.match(PATH_VERSION_REGEX)
      match&.[](:version)
    end

    def header_version(header)
      match = header.match(HEADER_VERSION_REGEX)
      match&.[](:version)
    end
  end
end
