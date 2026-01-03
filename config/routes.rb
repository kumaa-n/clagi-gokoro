Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }, skip: [:confirmations, :registrations]

  devise_scope :user do
    # Confirmations（メールアドレス確認のみ）
    get "/users/confirmation", to: "devise/confirmations#show", as: :user_confirmation

    # Registrations（新規登録のみ）
    get "/users/sign_up", to: "users/registrations#new", as: :new_user_registration
    post "/users", to: "users/registrations#create", as: :user_registration
  end

  root "home#index"

  %w[terms privacy contact].each do |page|
    get "/#{page}", to: "high_voltage/pages#show", id: page, format: false
  end

  post "/contacts", to: "contacts#create"

  resource :profile, only: %i[show edit update]
  resource :email_change, only: %i[edit update], controller: "users/email_changes"
  resource :nickname_change, only: %i[edit update], controller: "users/nickname_changes"

  resources :songs, only: %i[index new create] do
    collection do
      get :autocomplete
    end

    resources :reviews, shallow: true do
      resource :review_favorite, only: %i[create destroy]
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
