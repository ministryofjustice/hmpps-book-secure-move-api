require 'active_support/concern'

module SupplierPersonnelNumberValidations
  extend ActiveSupport::Concern

  included do
    if method_defined?(:supplier_personnel_number) || method_defined?(:supplier_personnel_numbers)
      validates_with PersonnelNumberValidation
    end
  end
end
