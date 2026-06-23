Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ] do
    scope module: :sessions do
      resource :magic_link, only: %i[ new create ]
    end
  end

  resources :activities
  post "mark_night_as_sleep(/:date)", to: "activities#mark_night_as_sleep", as: :mark_night_as_sleep

  namespace :activity do
    resources :categories
  end


  resource :calendar, only: :show
  resource :statistics, only: :show
  resources :settings, only: %i[ index update ]
  resource :account, only: :show

  get "up" => "rails/health#show", as: :rails_health_check

  root "activities#index"
end
