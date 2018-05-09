Rails.application.routes.draw do
  namespace :api, :path => "" do
    namespace :v1 do
      mount_devise_token_auth_for 'Member', at: 'auth'
    end
  end
end
