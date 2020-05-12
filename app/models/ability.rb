# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(application = nil)
    return unless application # no permissions

    if application.owner
      # owner is a supplier, suppliers can manage only their own locations
      can :manage, Move, Move.served_by(application.owner) do |move|
        move.from_location.suppliers.include?(application.owner)
      end
      can :manage, Journey, supplier_id: application.owner_id
    else
      # temporarily give all permissions to non-supplier accounts so as not to break compatibility with
      # the frontend application
      can :manage, Move
      can :manage, Journey
    end
  end
end
