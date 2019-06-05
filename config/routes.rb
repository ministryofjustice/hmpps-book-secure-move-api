Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json

  namespace :api do
    namespace :v1 do
      resources :moves, only: %i[index show destroy]
      namespace :reference do
        resources :locations, only: :index
        resources :profile_attribute_types, only: :index
        resources :genders, only: :index
        resources :ethnicities, only: :index
        resources :nationalities, only: :index
      end
    end
  end
end
