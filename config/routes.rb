Rails.application.routes.draw do
  namespace :api, :path => "" do
    namespace :v1 do
      mount_devise_token_auth_for 'Member', at: 'auth'
      resource :member
      get 'families', action: :index, controller: 'families'
      resource :family do #secured routes
        resource :member#, only [:index, :show]
      end
    end
  end
end
