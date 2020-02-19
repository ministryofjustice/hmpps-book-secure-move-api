# frozen_string_literal: true

class ApplicationController < ActionController::API
  def self.layout(_)
    'application'
  end
end
