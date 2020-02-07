# frozen_string_literal: true

class Document < ApplicationRecord
  has_one_attached :file

  before_validation :validate_file_presence

  belongs_to :move, optional: true

private

  def validate_file_presence
    errors.add(:file, I18n.t('errors.messages.blank')) unless file.attached?
  end
end
