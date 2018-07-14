Rails.application.routes.draw do

  namespace :api, :path => "" do
    namespace :v1 do
      resources :invites, only: [:create]
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
      resources :events_rsvps, only: [:create, :destroy]
      get 'families', action: :index, controller: 'families'
      # get 'family_dashboard', to: 'families#show'
      resources :events
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
