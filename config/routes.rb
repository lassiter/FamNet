Rails.application.routes.draw do
  namespace :api, :path => "" do
    namespace :v1 do
      mount_devise_token_auth_for 'Member', at: 'auth'
      resource :member
      resource :family 
      get 'families', action: :index, controller: 'families'
      # get 'family_dashboard', to: 'families#show'
      resources :posts do
        resources :comments
      end
    end
  end
end
