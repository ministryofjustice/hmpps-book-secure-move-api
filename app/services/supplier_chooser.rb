class SupplierChooser
  def initialize(doorkeeper_application_owner, from_location)
    @doorkeeper_application_owner = doorkeeper_application_owner
    @from_location = from_location
  end

  def call
    return @doorkeeper_application_owner if @doorkeeper_application_owner

    # TODO: Replace with the frontend supplied supplier
    #       There can only ever be one supplier per location, currently
    @from_location.suppliers.first
  end
end
