# frozen_string_literal: true

class NomisAlert < ApplicationRecord
  validates :nomis_alert_type, presence: true
  validates :nomis_alert_code, presence: true
  validates :nomis_alert_type_description, presence: true
  validates :nomis_alert_code_description, presence: true
end
