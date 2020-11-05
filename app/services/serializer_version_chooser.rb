# frozen_string_literal: true

class SerializerVersionChooser
  DEFAULT_API_VERSION = 'V2'

  def self.call(interpolatable)
    serializer = "#{DEFAULT_API_VERSION}::#{interpolatable.to_s.singularize.camelize}Serializer"

    serializer = if const_defined?(serializer)
                   serializer
                 else
                   serializer.sub("#{DEFAULT_API_VERSION}::", '')
                 end

    serializer.constantize
  end
end
