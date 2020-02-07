# frozen_string_literal: true

# This is 'our' application model, which knows that there are read audits attached.
class Application < Doorkeeper::Application
  has_many :request_audits, dependent: :destroy
end
