# frozen_string_literal: true

namespace :lockout_moves do
  desc 'lockouts a move which containts a MoveLockut in its generic events'
  task lockout_moves: :environment do

    Move.all.each do |move|
      move_events = move.generic_events 

      move_events.each do |event|
        if event.type == "GenericEvent::MoveLockout"
          move.is_lockout = true
          break
        end
      end
    end
    
  end
end