# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user
      can :manage, Move, Move.served_by(user)
    else
      can :manage, Move
    end
  end
end
