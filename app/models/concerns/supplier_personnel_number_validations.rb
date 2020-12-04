require 'active_support/concern'

module SupplierPersonnelNumberValidations
  extend ActiveSupport::Concern

  included do
    validates :supplier_personnel_number, presence: true if method_defined?(:supplier_personnel_number)

    validates :supplier_personnel_numbers, presence: true if method_defined?(:supplier_personnel_numbers)
  end
end
