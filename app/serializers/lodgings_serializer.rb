# frozen_string_literal: true

class LodgingsSerializer
  include JSONAPI::Serializer

  set_type :lodgings

  attributes :start_date,
             :end_date

  belongs_to :move
  belongs_to :location
end
