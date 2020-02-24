Rails.application.routes.draw do
  use_doorkeeper

  if !Rails.env.production? || ENV['SERVE_API_DOCS']
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get "/docs/*id" => 'pages#show', as: :page, format: false
  get 'docs/', to: 'pages#show', id: 'overview'

  get '/ping', to: 'status#ping', format: :json
  get '/health', to: 'status#health', format: :json

  namespace :api do
    namespace :v1 do
      resources :documents, only: %i[create]
      resources :people, only: %i[index create update]
      resources :moves, only: %i[index show create destroy update] do
        resources :documents, only: %i[create destroy]
      end
      namespace :reference do
        resources :locations, only: %i[index show]
        resources :assessment_questions, only: :index
        resources :genders, only: :index
        resources :ethnicities, only: :index
        resources :nationalities, only: :index
        resources :identifier_types, only: :index
        resources :suppliers, only: %i[index show]
      end
    end
  end
end
