Rails.application.routes.draw do
  use_doorkeeper

  if !Rails.env.production? || ENV['SERVE_API_DOCS']
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/health', to: 'status#health', format: :json
  get '/ping', to: 'status#ping', format: :json

  namespace :api do
    namespace :v1 do
      resources :allocations, only: %i[create index show] do
        resources :events, only: %i[create], controller: 'allocation_events'
      end
      resources :court_hearings, only: %i[create]
      resources :documents, only: %i[create]
      resources :people, only: %i[index create update] do
        get 'images', to: 'people#image'
        get 'court_cases', to: 'people#court_cases'
        get 'timetable', to: 'people#timetable'
      end
      resources :moves, only: %i[index show create update] do
        resources :documents, only: %i[create destroy]
        resources :journeys, only: %i[index show create update]
        member do
          post 'events', controller: 'move_events' # TODO: delete this route once the front end is updated
          post 'cancel', controller: 'move_events'
          post 'complete', controller: 'move_events'
          post 'lockouts', controller: 'move_events'
          post 'redirects', controller: 'move_events'
        end
      end
      namespace :reference do
        resources :allocation_complex_cases, only: :index
        resources :assessment_questions, only: :index
        resources :ethnicities, only: :index
        resources :genders, only: :index
        resources :identifier_types, only: :index
        resources :locations, only: %i[index show]
        resources :nationalities, only: :index
        resources :prison_transfer_reasons, only: %i[index]
        resources :regions, only: :index
        resources :suppliers, only: %i[index show]
      end
    end

    namespace :v2 do
      resources :people, only: %i[index create update]
    end
  end
end
