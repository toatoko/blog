Rails.application.routes.draw do
  authenticated :user, ->(user) {user.admin?} do
    get "admin", to: "admin#index"
    get "admin/posts"
    get "admin/comments"
    get "admin/users"
    get "admin/show_post/:id" , to: "admin#show_post", as: "admin_post"
  end
  get "search", to: "search#index"
  get "users/profile"
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  get "/u/:id", to: "users#profile", as: "user"

  # ?posts/1/comments/4
  resources :posts do
    resources :comments
  end
  mount ActionText::Engine => "/action_text"

  get "about", to: "pages#about"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
