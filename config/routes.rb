Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "povezi-zelje", to: "link_wishes#show", as: :link_wishes
  post "povezi-zelje/da", to: "link_wishes#accept", as: :accept_link_wishes
  post "povezi-zelje/ne", to: "link_wishes#decline", as: :decline_link_wishes

  root "wishes#index"
  resources :wishes, only: [:create, :show, :destroy] do
    member do
      get :matches
      delete :disown
    end
    resource :vote, only: [:create]
    resources :comments, only: [:create]
  end
  get "statistika", to: "stats#index"
  get "profil/:token", to: "profiles#show", as: :profile
  delete "profil", to: "profiles#forget", as: :forget_profile
  delete "profil/odklopi", to: "profiles#unlink", as: :unlink_profile
  get "oznaka/:tag", to: "tags#show", as: :tag
  resources :articles, only: [:index, :show], path: "clanki" do
    resources :article_reactions, only: [:create], path: "odzivi"
    resources :comments, only: [:create]
  end
  get "o-projektu", to: "pages#about", as: :about
  get "prompt", to: "pages#prompt", as: :prompt
end
