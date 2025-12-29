Rails.application.routes.draw do
  # Standardizing the Devise routes for API use.
  # This registers the mapping globally for the /api/v1/auth path.
  devise_for :users,
             path: "api/v1/auth",
             path_names: { sign_in: "login", sign_out: "logout" },
             controllers: {
               sessions: "api/v1/auth/sessions",
               registrations: "api/v1/auth/registrations",
               passwords: "api/v1/auth/passwords"
             }

  namespace :api do
    namespace :v1 do
      get "users/me", to: "users#me"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
