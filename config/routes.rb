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
        member do
          post 'cancel', controller: 'allocation_events'
        end
      end
      resources :court_hearings, only: %i[create]
      resources :documents, only: %i[create]
      resources :people, only: %i[index create update] do
        get 'images', to: 'people#image'
        get 'court_cases', to: 'people#court_cases'
        get 'timetable', to: 'people#timetable'

        resources :profiles, only: %i[create update]
      end
      resources :moves, only: %i[index show create update] do
        resources :documents, only: %i[create destroy]
        resources :journeys, only: %i[index show create update] do
          member do
            post 'cancel', controller: 'journey_events'
            post 'complete', controller: 'journey_events'
            post 'lockouts', controller: 'journey_events'
            post 'lodgings', controller: 'journey_events'
            post 'reject', controller: 'journey_events'
            post 'start', controller: 'journey_events'
            post 'uncancel', controller: 'journey_events'
            post 'uncomplete', controller: 'journey_events'
          end
        end
        member do
          post 'accept', controller: 'move_events'
          post 'cancel', controller: 'move_events'
          post 'complete', controller: 'move_events'
          post 'lockouts', controller: 'move_events'
          post 'redirects', controller: 'move_events'
          post 'approve', controller: 'move_events'
          post 'reject', controller: 'move_events'
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
