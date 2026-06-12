Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ] do
    scope module: :sessions do
      resource :magic_link, only: %i[ new create ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
end
