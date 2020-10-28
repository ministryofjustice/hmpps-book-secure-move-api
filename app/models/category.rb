class Category
  TYPE = 'Category'.freeze

  attr_reader :id, :title, :move_supported

  def build_from_nomis(booking_details)
    @id = booking_details[:category_code]
    @title = booking_details[:category]
    @move_supported = Move::UNSUPPORTED_PRISONER_CATEGORIES.exclude?(id)

    self
  end
end
