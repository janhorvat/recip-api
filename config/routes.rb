Rails.application.routes.draw do
 namespace :api do
    namespace :v1 do
      post 'photos/upload' => 'photos#upload'
      #resources :tinks, :defaults => { :format => 'json' }
    end
  end
end
