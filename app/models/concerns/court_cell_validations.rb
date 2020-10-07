require 'active_support/concern'

module CourtCellValidations
  extend ActiveSupport::Concern

  def court_cell_number=(court_cell_number)
    details['court_cell_number'] = court_cell_number
  end

  def court_cell_number
    details['court_cell_number']
  end

  included do
    validates :court_cell_number, presence: true
  end
end
