Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, :path => "", :default => { :format => :json }, :constraints => {:subdomain => "api"} do
    namespace :v1 do
      devise_for :members,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }
      resource :member, :only => [] do #secured routes
        resource :family
      end
    end
  end
end
