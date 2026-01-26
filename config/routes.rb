Rails.application.routes.draw do
  get "pages/home"

  # Login (handles both admin password and regular OTP)
  get  "login",                 to: "otp_sessions#new"
  post "login",                 to: "otp_sessions#create"
  get  "login/password",        to: "otp_sessions#password",    as: :login_password
  post "login/password",        to: "otp_sessions#authenticate"
  get  "login/verify/:token",   to: "otp_sessions#verify",      as: :login_verify
  post "login/verify/:token",   to: "otp_sessions#confirm"
  delete "logout",              to: "otp_sessions#destroy"

  # Registration
  get  "signup",                to: "registrations#new"
  post "signup",                to: "registrations#create"
  get  "signup/verify/:token",  to: "registrations#verify",     as: :signup_verify
  post "signup/verify/:token",  to: "registrations#confirm"

  resources :participants
  resources :matches
  resources :events
  resources :betting_pools do
    resources :betting_pool_memberships, shallow: true
  end
  resources :predictions do
    collection do
      post :upsert
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [ :index, :edit, :update ]
    resources :tournaments, only: [] do
      collection do
        get :import
        post :create_from_json
      end
    end
  end

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
