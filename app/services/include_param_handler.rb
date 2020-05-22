class IncludeParamHandler
  SEPARATOR = ','.freeze

  def initialize(params)
    @params = params
  end

  def call
    @params.fetch[:include]&.split(SEPARATOR)
  end
end
