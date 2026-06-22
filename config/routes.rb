Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ] do
    scope module: :sessions do
      resource :magic_link, only: %i[ new create ]
    end
  end

  resources :activities
  namespace :activity do
    resources :categories
  end

  resources :settings, only: %i[ index update ]

  resource :calendar, only: :show

  get "up" => "rails/health#show", as: :rails_health_check

  root "activities#index"
end
