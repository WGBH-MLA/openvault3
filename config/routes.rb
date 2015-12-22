Rails.application.routes.draw do
  root to: "home#index"
  blacklight_for :catalog
  
  resources :collections,
    only: [:index, :show]
  
  resources :exhibits,
    only: [:index, :show]
  
  resources :series,
    only: [:index]
  
  resources :about,
    only: [:show]
end
