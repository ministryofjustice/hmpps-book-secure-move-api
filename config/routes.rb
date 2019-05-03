Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json

  namespace :api do
    namespace :v1 do
      resources :moves, only: :index
    end
  end
end
