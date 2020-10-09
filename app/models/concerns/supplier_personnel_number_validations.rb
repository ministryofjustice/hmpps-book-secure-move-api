require 'active_support/concern'

module SupplierPersonnelNumberValidations
  extend ActiveSupport::Concern

  def supplier_personnel_number=(supplier_personnel_number)
    details['supplier_personnel_number'] = supplier_personnel_number
  end

  def supplier_personnel_number
    details['supplier_personnel_number']
  end

  included do
    validates :supplier_personnel_number, presence: true
  end
end
