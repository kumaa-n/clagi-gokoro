Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root "home#index"

  %w[terms privacy contact].each do |page|
    get "/#{page}", to: "high_voltage/pages#show", id: page, format: false
  end

  resource :profile, only: %i[show edit update]

  resources :songs, only: %i[index new create], param: :short_uuid do
    resources :reviews, shallow: true do
      resource :review_favorite, only: %i[create destroy]
    end
  end
end
