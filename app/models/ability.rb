# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user
      can :manage, Move, Move.served_by(user) do |move|
        move.from_location.suppliers.include?(user)
      end
    else
      can :manage, Move
    end
  end
end
