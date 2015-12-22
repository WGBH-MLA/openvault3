Rails.application.routes.draw do
  root to: "home#index"
  blacklight_for :catalog # If I change this we get errors from the other pages.
  
  get 'collections', to: 'collections#index'
  get 'collections/:id/:tab', to: 'collections#show'
  
  get 'exhibits', to: 'exhibits#index'
  get 'exhibits/:id/:tab', to: 'exhibits#show'
  
  resources :series,
    only: [:index]
  
  resources :about,
    only: [:show]
end
