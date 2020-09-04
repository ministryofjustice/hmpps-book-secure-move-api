class SupplierChooser
  attr_accessor :move_or_allocation

  def initialize(move_or_allocation)
    self.move_or_allocation = move_or_allocation
  end

  def call
    return unless effective_date.present? && location.present?

    # NB: business rules _should_ preclude multiple suppliers for visibility
    supplier_location = SupplierLocation.location(location.id).effective_on(effective_date).first
    supplier_location&.supplier
  end

private

  def effective_date
    @effective_date ||= begin
      return move_or_allocation.date if move_or_allocation.date.present?

      move_or_allocation.date_from if move_or_allocation.respond_to?(:date_from)
    end
  end

  def location
    @location ||= move_or_allocation.from_location
  end
end
