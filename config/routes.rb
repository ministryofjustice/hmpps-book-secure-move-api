require 'routing_filter/versioned_path'

Rails.application.routes.draw do
  use_doorkeeper

  if !Rails.env.production? || ENV['SERVE_API_DOCS']
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/health', to: 'status#health', format: :json
  get '/ping', to: 'status#ping', format: :json
  get '/diagnostics/moves/:id', to: 'diagnostics#move'

  namespace :api do
    filter :versioned_path

    resources :events, only: %i[create], controller: 'generic_events'

    resources :allocations, only: %i[create index show] do
      collection { post 'filtered' }
      member do
        post 'cancel', controller: 'allocation_events'
      end
    end
    resources :court_hearings, only: %i[create]
    resources :documents, only: %i[create]
    resources :people, only: %i[index show create update] do
      get 'images', to: 'people#image'
      get 'court_cases', to: 'people#court_cases'
      get 'timetable', to: 'people#timetable'

      resources :profiles, only: %i[create update]
    end
    resources :moves, only: %i[index show create update] do
      collection do
        post 'csv'
        post 'filtered'
      end
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
        post 'approve', controller: 'move_events'
        post 'cancel', controller: 'move_events'
        post 'complete', controller: 'move_events'
        post 'lockouts', controller: 'move_events'
        post 'redirects', controller: 'move_events'
        post 'reject', controller: 'move_events'
        post 'start', controller: 'move_events'
      end
    end

    resources :person_escort_records, only: %i[create show update] do
      member do
        patch 'framework_responses', to: 'framework_responses#bulk_update', assessment_class: PersonEscortRecord
      end
    end

    resources :youth_risk_assessments, only: %i[create show update] do
      member do
        patch 'framework_responses', to: 'framework_responses#bulk_update', assessment_class: YouthRiskAssessment
      end
    end

    resources :framework_responses, only: %i[update]

    get 'locations_free_spaces', to: 'populations#index'
    resources :populations, only: %i[new show create update]

    namespace :reference do
      resources :allocation_complex_cases, only: :index
      resources :assessment_questions, only: :index
      resources :categories, only: %i[index]
      resources :ethnicities, only: :index
      resources :genders, only: :index
      resources :identifier_types, only: :index
      resources :locations, only: %i[index show]
      resources :nationalities, only: :index
      resources :prison_transfer_reasons, only: %i[index]
      resources :regions, only: %i[index show]
      resources :suppliers, only: %i[index show]
    end

    get '/suppliers/:supplier_id/locations', to: 'suppliers#locations'
  end
end
