class GenericEvent
  class MoveDateChanged < GenericEvent
    details_attributes :date
    eventable_types 'Move'

    validates :date, presence: true, iso_date_time: true
  end
end
