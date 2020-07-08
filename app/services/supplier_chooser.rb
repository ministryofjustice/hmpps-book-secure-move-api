class SupplierChooser
  def initialize(doorkeeper_application_owner, move)
    @doorkeeper_application_owner = doorkeeper_application_owner
    @move = move
  end

  def call
    return @doorkeeper_application_owner if @doorkeeper_application_owner

    # TODO: Replace with the frontend supplied supplier
    #       There can only ever be one supplier per location, currently
    @move.from_location.suppliers.first
  end
end
