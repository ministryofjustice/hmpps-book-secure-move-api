Rails.application.routes.draw do
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json
end
