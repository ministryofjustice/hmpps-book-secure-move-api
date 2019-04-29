Rails.application.routes.draw do
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json

  root to: 'home#index'
  get '/auth/:provider/new', to: 'sessions#new'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/logout', to: 'sessions#destroy'

  namespace :api do
    namespace :v1 do
      resources :moves, only: :index
    end
  end
end
