# frozen_string_literal: true

namespace :inspect do
  desc 'Inspects a move, rake inspect:move '
  task :move, [:id_or_ref] => :environment do |_, args|
    abort "Please specify a move id or move reference, e.g. $ rake 'inspect:move[ABC1234X]'" if args[:id_or_ref].blank?
    move = Move.find_by(id: args[:id_or_ref]) || Move.find_by(reference: args[:id_or_ref])
    abort "Could not find move record with id or reference: #{args[:id_or_ref]}" if move.blank?

    puts Diagnostics::MoveInspector.new(move).generate
  end
end
