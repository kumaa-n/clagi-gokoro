Rails.application.routes.draw do
  devise_for :users, only: %i[sessions registrations]

  root "static_pages#top"

  resources :songs, only: %i[index new create] do
    resources :reviews do
      resources :review_comments, only: %i[create show edit update]
    end
  end
end
