Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Server-rendered app (doctor + admin) -------------------------------
  root "sessions#new"

  resource :session, only: [ :new, :create, :destroy ]

  namespace :doctor do
    root "dashboard#show", as: :root
    get "calendar", to: "calendar#show", as: :calendar
    resources :availability_rules, only: [ :create, :destroy ]
    resources :blocked_slots, only: [ :create, :destroy ]
    resources :appointments, only: [ :new, :create, :edit, :update, :destroy ]
  end

  namespace :admin do
    root "doctors#index", as: :root
    resources :doctors, only: [ :index, :new, :create, :edit, :update ]
    resources :appointments, only: [ :index ]
  end
end
