class SupplierChooser
  attr_accessor :effective_date, :location, :new_record, :doorkeeper_application_owner, :existing_owner

  def initialize(effective_date:, location:, new_record:, doorkeeper_application_owner: nil, existing_owner: nil)
    @effective_date = effective_date
    @location = location
    @new_record = new_record
    @doorkeeper_application_owner = doorkeeper_application_owner
    @existing_owner = existing_owner
  end

  # CREATING NEW RECORDS
  # | Doorkeeper App Owner | Location+Date Owner | Resulting Owner |
  # |----------------------|---------------------|-----------------|
  # | nil                  | nil                 | nil             |
  # | nil                  | Supplier1           | Supplier1       |
  # | nil                  | Supplier2           | Supplier2       |
  #
  # | Supplier1            | nil                 | Supplier1       |
  # | Supplier1            | Supplier1           | Supplier1       |
  # | Supplier1            | Supplier2           | Supplier1       |
  #
  # | Supplier2            | nil                 | Supplier2       |
  # | Supplier2            | Supplier1           | Supplier2       |
  # | Supplier2            | Supplier2           | Supplier2       |

  # UPDATING EXISTING RECORDS
  # | Location+Date Owner | Existing Owner | Doorkeeper App Owner | Resulting Owner |
  # |---------------------|----------------|----------------------|-----------------|
  # | nil                 | nil            | nil                  | nil             |
  # | nil                 | nil            | Supplier1            | Supplier1       |
  # | nil                 | nil            | Supplier2            | Supplier2       |
  #
  # | nil                 | Supplier1      | nil                  | Supplier1       |
  # | nil                 | Supplier1      | Supplier1            | Supplier1       |
  # | nil                 | Supplier1      | Supplier2            | Supplier1       |
  #
  # | nil                 | Supplier2      | nil                  | Supplier2       |
  # | nil                 | Supplier2      | Supplier1            | Supplier2       |
  # | nil                 | Supplier2      | Supplier2            | Supplier2       |
  #
  # | Supplier1           | nil            | nil                  | Supplier1       |
  # | Supplier1           | nil            | Supplier1            | Supplier1       |
  # | Supplier1           | nil            | Supplier2            | Supplier1       |
  #
  # | Supplier1           | Supplier1      | nil                  | Supplier1       |
  # | Supplier1           | Supplier1      | Supplier1            | Supplier1       |
  # | Supplier1           | Supplier1      | Supplier2            | Supplier1       |
  #
  # | Supplier1           | Supplier2      | nil                  | Supplier1       |
  # | Supplier1           | Supplier2      | Supplier1            | Supplier1       |
  # | Supplier1           | Supplier2      | Supplier2            | Supplier1       |
  #
  # | Supplier2           | nil            | nil                  | Supplier2       |
  # | Supplier2           | nil            | Supplier1            | Supplier2       |
  # | Supplier2           | nil            | Supplier2            | Supplier2       |
  #
  # | Supplier2           | Supplier1      | nil                  | Supplier2       |
  # | Supplier2           | Supplier1      | Supplier1            | Supplier2       |
  # | Supplier2           | Supplier1      | Supplier2            | Supplier2       |
  #
  # | Supplier2           | Supplier2      | nil                  | Supplier2       |
  # | Supplier2           | Supplier2      | Supplier1            | Supplier2       |
  # | Supplier2           | Supplier2      | Supplier2            | Supplier2       |

  def call
    if new_record
      doorkeeper_application_owner || effective_supplier_for_location
    else
      effective_supplier_for_location || existing_owner || doorkeeper_application_owner
    end
  end

private

  def effective_supplier_for_location
    # NB: business rules _should_ preclude multiple effective suppliers for a given location
    return unless effective_date.present? && location.present?

    SupplierLocation
        .location(location.id)
        .effective_on(effective_date)
        .first
        &.supplier
  end
end
