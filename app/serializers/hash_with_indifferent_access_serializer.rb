# frozen_string_literal: true

# Based on: https://nandovieira.com/using-postgresql-and-jsonb-with-ruby-on-rails
class HashWithIndifferentAccessSerializer
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    (hash || {}).with_indifferent_access
  end
end
