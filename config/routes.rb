Rails.application.routes.draw do
  get 'reactions/index'
  get 'reactions/show'
  get 'reactions/create'
  get 'reactions/destroy'
  namespace :api, :path => "" do
    namespace :v1 do
      mount_devise_token_auth_for 'Member', at: 'auth'
      resource :member
      resource :family 
      resources :reactions, only: [:create, :destroy]
      resources :events_rsvps, only: [:create, :destroy]
      get 'families', action: :index, controller: 'families'
      # get 'family_dashboard', to: 'families#show'
      resources :posts do
        resources :reactions, only: [:index]
        resources :comments do
          resources :reactions, only: [:index]
          resources :comment_replys do
            resources :reactions, only: [:index]
          end
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
