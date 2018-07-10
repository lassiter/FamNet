Rails.application.routes.draw do

  namespace :api, :path => "" do
    namespace :v1 do
      mount_devise_token_auth_for 'Member', at: 'auth', controllers: {
        :sessions => 'devise_token_auth/sessions',
        :registrations => 'api/v1/registrations',
        :passwords => 'devise_token_auth/passwords',
        :token_validations => 'devise_token_auth/token_validations'
      }
      resources :reaction, only: [:create, :destroy]
      resources :members, :except => [:create]
      get 'directory', action: :index, controller: 'members'
      resources :family 
      resources :reactions, only: [:create, :destroy]
      get 'families', action: :index, controller: 'families'
      # get 'family_dashboard', to: 'families#show'
      resources :events_rsvps, only: [:index, :show]
      resources :events do
        resources :events_rsvps
      end
      resources :posts do
        resources :reactions, only: [:index]
        resources :comments do
          resources :reactions, only: [:index]
          resources :comment_replys do
            resources :reactions, only: [:index]
          end
        end
      end
      resources :comments do
        resources :reactions, only: [:index]
        resources :comment_replys do
          resources :reactions, only: [:index]
        end
      end
      resource :recipes do
        collection do
          get 'search'
        end
        resources :reactions, only: [:index]
      end
    end
  end
end
