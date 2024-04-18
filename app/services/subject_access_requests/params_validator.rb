# frozen_string_literal: true

module SubjectAccessRequests
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :prn, :from_date, :to_date

    validates_each :from_date, :to_date, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validate do
      errors.add :prn, 'must be supplied' if @prn.blank? && @crn.blank?
    end

    def initialize(sar_params)
      @prn = sar_params[:prn]
      @crn = sar_params[:crn]

      @from_date = sar_params[:from_date]
      @to_date = sar_params[:to_date]
    end
  end
end
