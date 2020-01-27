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
    else
      # momentarily give all permissions to not break compatibility with
      # the frontend application
      can :manage, Move
    end
  end
end
