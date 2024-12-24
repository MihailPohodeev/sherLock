Rails.application.routes.draw do
  resources :users, only: [ :create, :show, :destroy, :update ] do
    # Вложенный ресурс для объявлений пользователя
    get "advertisements", to: "users#advertisement_of_user", on: :member
    member do
      patch :update_avatar
    end
  end

  # Для входа в систему и подтверждения аккаунта можно использовать отдельные маршруты
  post "users/login", to: "users#login"
  post "users/confirm", to: "users#confirm"


  resources :advertisements, only: [ :show, :create, :index ] do
    collection do
      get "all", to: "advertisements#all" # Для получения всех объявлений
      get "filter", to: "advertisements#filter"
    end
  end

  # Добавьте маршруты для чатов и сообщений
  resources :chats, only: [ :create, :show ] do
    resources :messages, only: [ :create ]
  end

  mount ActionCable.server => '/cable'
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
