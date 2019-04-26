Rails.application.routes.draw do
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json

  root to: 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'

  namespace :api do
    namespace :v1 do
      resources :moves, only: :index
    end
  end
end
