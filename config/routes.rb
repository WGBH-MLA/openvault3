Rails.application.routes.draw do
  root to: "home#index"
  blacklight_for :catalog
  
  resources :collections,
    only: [:show]
  
  resources :about,
    only: [:show]
end
