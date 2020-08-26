class SupplierChooser
  attr_accessor :effective_date, :location

  def initialize(effective_date, location)
    self.effective_date = effective_date
    self.location = location
  end

  def call
    return unless effective_date.present? && location.present?

    # NB: business rules _should_ preclude multiple suppliers for visibility
    supplier_location = SupplierLocation.location(location.id).effective_on(effective_date).first
    supplier_location&.supplier
  end
end
