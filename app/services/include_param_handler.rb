class IncludeParamHandler
  SEPARATOR = ','.freeze

  def initialize(params)
    @params = params
  end

  def call
    @params[:include]&.split(SEPARATOR)
  end
end
