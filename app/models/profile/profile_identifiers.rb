# frozen_string_literal: true

class Profile
  class ProfileIdentifiers < Types::BaseCollection
    def concrete_class
      ProfileIdentifier
    end

    def remove_empty_items?
      true
    end
  end
end
