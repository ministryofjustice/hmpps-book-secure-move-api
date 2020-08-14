# frozen_string_literal: true

class Document < ApplicationRecord
  include Discard::Model

  self.ignored_columns = %w[move_id]

  has_one_attached :file

  before_validation :validate_file_presence

  belongs_to :move, optional: true
  belongs_to :documentable, polymorphic: true, optional: true

private

  def validate_file_presence
    errors.add(:file, I18n.t('errors.messages.blank')) unless file.attached?
  end
end
