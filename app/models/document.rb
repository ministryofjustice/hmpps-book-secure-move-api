# frozen_string_literal: true

class Document < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64

  has_one_base64_attached :file

  before_validation :validate_file_presence
  validates :document_type, presence: true

  belongs_to :move

  private

  def validate_file_presence
    errors.add(:file, I18n.t('errors.messages.blank')) unless file.attached?
  end
end
