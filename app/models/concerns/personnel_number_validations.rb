require 'active_support/concern'

module PersonnelNumberValidations
  extend ActiveSupport::Concern

  included do
    if method_defined?(:supplier_personnel_number) ||
        method_defined?(:supplier_personnel_numbers) ||
        method_defined?(:police_personnel_number) ||
        method_defined?(:police_personnel_numbers)
      validates_with PersonnelNumberValidation
    end
  end
end
