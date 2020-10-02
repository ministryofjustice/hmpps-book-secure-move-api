module Metrics
  class MoveCountsSupplierVsStatus
    include Metric

    def initialize
      self.label = 'Move counts by status and supplier'
      self.interval = 5.minutes
    end

    def columns
      @columns ||= Supplier.all + [nil]
    end

    def column_heading(supplier)
      supplier.present? ? supplier.name : 'none'
    end

    def rows
      @rows ||= Move.statuses.values
    end

    def row_label(status)
      status
    end

    def value(status, supplier)
      Move.where(supplier: supplier).where(status: status).count
    end
  end
end
