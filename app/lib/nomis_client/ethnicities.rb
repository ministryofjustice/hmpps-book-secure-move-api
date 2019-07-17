# frozen_string_literal: true

class NomisClient
  class Ethnicities
    class << self
      def get
        NomisClient.get('/reference-domains/domains/ETHNICITY').parsed
      end
    end
  end
end
