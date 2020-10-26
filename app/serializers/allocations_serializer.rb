# frozen_string_literal: true

class AllocationsSerializer < AllocationSerializer
  meta do |object, params|
    {
      moves: params[object.id],
    }
  end
end
