class CourtHearing < ApplicationRecord
  belongs_to :move

  validates_presence_of :start_time
end
