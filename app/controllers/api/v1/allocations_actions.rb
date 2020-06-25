module Api::V1
  module AllocationsActions
    def included_relationships
      IncludeParamHandler.new(params).call || AllocationSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
