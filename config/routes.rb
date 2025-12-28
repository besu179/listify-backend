Rails.application.routes.draw do
  devise_for :users, skip: %i[sessions registrations passwords]

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
      end
      get "users/me", to: "users#me"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
