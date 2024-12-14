Rails.application.routes.draw do
  
  post 'sign_in', to: 'users#login'
  post 'confirm_account', to: 'users#confirm'
  post 'sign_up', to: 'users#create'
  delete 'drop_user', to: 'users#destroy' # This can be used to delete a user


  resources :advertisements, only: [ :show, :create] do
    collection do
      get 'all', to: 'advertisements#all' # Для получения всех объявлений
    end
  end
  # get "/get_"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
