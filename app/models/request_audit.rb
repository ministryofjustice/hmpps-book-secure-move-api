class RequestAudit < ApplicationRecord
  belongs_to :application, class_name: 'Doorkeeper::Application'
  has_many :response_audits, dependent: :destroy
end
