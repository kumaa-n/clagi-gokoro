Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root "static_pages#top"

  resources :songs, only: %i[index new create], param: :short_uuid do
    resources :reviews, shallow: true do
      resource :review_favorite, only: %i[create destroy]
    end
  end
end
