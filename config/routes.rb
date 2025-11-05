Rails.application.routes.draw do
  devise_for :users, only: %i[sessions registrations]

  root "static_pages#top"

  resources :songs, only: %i[index new create] do
    resources :reviews, only: %i[index new create edit update destroy]
  end
end
