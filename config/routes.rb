Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, :path => "", :default => { :format => :json }, :constraints => {:subdomain => "api"} do
    namespace :v1 do
      resource :member, :only => [] do #secured routes
        resource :family
      end
    end
  end
end
