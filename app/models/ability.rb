# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(application = nil)
    return unless application # no permissions

    if application.owner
      can :manage, Move, Move.for_supplier(application.owner) do |move|
        move.supplier == application.owner ||
          move.from_location&.suppliers&.include?(application.owner) ||
          move.to_location&.suppliers&.include?(application.owner) ||
          move.lodgings.any? { |lodging| lodging.location.suppliers.include?(application.owner) }
      end

      can :manage, Journey, supplier_id: application.owner_id
    else
      can :manage, Move
      can :manage, Journey
      can :manage, Lodging
    end
  end
end
