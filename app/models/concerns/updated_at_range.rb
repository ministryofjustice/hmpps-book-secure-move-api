module UpdatedAtRange
  extend ActiveSupport::Concern

  included do
    scope :updated_at_range, lambda { |from, to|
      where(updated_at: from..to)
    }
  end
end
