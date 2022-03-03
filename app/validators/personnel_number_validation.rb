class PersonnelNumberValidation < ActiveModel::Validator
  def validate(record)
    validate_numbers(record, :supplier_personnel_number, :police_personnel_number)
    validate_numbers(record, :supplier_personnel_numbers, :police_personnel_numbers)
  end

private

  def validate_numbers(record, supplier_field, police_field)
    if record.respond_to?(supplier_field) || record.respond_to?(police_field)
      supplier = record.try(supplier_field)
      police = record.try(police_field)

      if supplier.present? && police.present?
        record.errors.add police_field, 'should be blank'
      elsif supplier.blank? && police.blank?
        record.errors.add supplier_field, "can't be blank"
      end
    end
  end
end
