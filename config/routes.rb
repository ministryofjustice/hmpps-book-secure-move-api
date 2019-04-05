Rails.application.routes.draw do
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :moves, only: :index
end
