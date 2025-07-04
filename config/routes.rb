Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Handle legacy ActionCable assets route
  get "assets/channels", to: proc { [200, {}, [""]] }

  # Internationalization routes
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    # Defines the root path route ("/")
    root "rounds#index"

    resources :rounds
    resources :players
    resources :bets

    # Analytics
    get "analytics/dashboard", to: "analytics#dashboard", as: :analytics_dashboard
  end

  # == Sidekiq Web UI ==
  # Uncomment the following lines to enable Sidekiq Web UI in development:
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  # == Action Cable ==
  mount ActionCable.server => "/cable"
end
