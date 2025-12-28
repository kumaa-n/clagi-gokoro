Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }

  root "home#index"

  %w[terms privacy contact].each do |page|
    get "/#{page}", to: "high_voltage/pages#show", id: page, format: false
  end

  post "/contacts", to: "contacts#create"

  resource :profile, only: %i[show edit update]
  resource :email_change, only: %i[edit update], controller: "users/email_changes"

  resources :songs, only: %i[index new create], param: :short_uuid do
    resources :reviews, shallow: true do
      resource :review_favorite, only: %i[create destroy]
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
