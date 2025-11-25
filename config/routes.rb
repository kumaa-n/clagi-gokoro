Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "static_pages#top"

  resources :songs, only: %i[index new create], param: :short_uuid do
    resources :reviews, shallow: true
  end
end
