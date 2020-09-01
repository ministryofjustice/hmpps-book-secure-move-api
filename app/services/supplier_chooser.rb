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

    # FIXME: This is a very temporary solution to the issue of suppliers not being able to create
    # moves for locations that have not been mapped in the supplier_locatations.yml files.
    # Only one supplier (Serco) is going live initially so we can assume that any moves created that
    # don't have a mapped supplier location are ones created by Serco. This can be replaced by a
    # smarter solution in the very near future.
    supplier_location&.supplier || Supplier.find_by(key: 'serco')
  end
end
