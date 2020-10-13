# frozen_string_literal: true

class LocationFreeSpacesSerializer
  include JSONAPI::Serializer

  set_type :locations

  attributes :title

  meta do |object, params|
    {
      populations: params[:populations][object.id],
    }
  end
end
