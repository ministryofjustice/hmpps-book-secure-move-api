require 'active_support/concern'

module CourtCellValidations
  extend ActiveSupport::Concern

  included do
    validates :court_cell_number, presence: true
  end
end
