Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :leaderboards do
        get :accuracy, to: "accuracy#index"
        get :best, to: "best_players#show"
        get :medals, to: "medals#index"
        get :damage_dealt, to: "damage#damage_dealt"
        get :damage, to: "damage#damage_dealt"
        get :damage_taken, to: "damage#damage_taken"
        get :kills, to: "kills_deaths#kills"
        get :deaths, to: "kills_deaths#deaths"
        get :kills_deaths_ratio, to: "kills_deaths#kills_deaths_ratio"
        get :wins, to: "wins_losses#wins"
        get :losses, to: "wins_losses#losses"
        get :play_time, to: "play_time#play_time"
        get :time, to: "play_time#play_time"
      end

      get :stats, to: "leaderboards/accuracy#show"
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
