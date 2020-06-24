module Api::V2
  module AllocationsActions
    def included_relationships
      IncludeParamHandler.new(params).call
    end
  end
end
