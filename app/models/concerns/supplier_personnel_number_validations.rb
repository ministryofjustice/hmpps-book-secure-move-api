require 'active_support/concern'

module SupplierPersonnelNumberValidations
  extend ActiveSupport::Concern

  included do
    validates :supplier_personnel_number, presence: true
  end
end
