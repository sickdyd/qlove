Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :leaderboards do
        get :accuracy, to: "accuracy#show"
        get :best_players, to: "best_players#show"
        get :damage_dealt, to: "damage#damage_dealt"
        get :damage_taken, to: "damage#damage_taken"
        get :kills, to: "kills_deaths#kills"
        get :deaths, to: "kills_deaths#deaths"
        get :wins, to: "wins_losses#wins"
        get :losses, to: "wins_losses#losses"
      end
      get :stats, to: "stats#show"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
