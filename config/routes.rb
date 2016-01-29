Rails.application.routes.draw do
  root to: 'home#index'
  blacklight_for :catalog # If I change this we get errors from the other pages.

  get 'collections', to: 'collections#index'
  get 'collections/:id/:tab', to: 'collections#show'

  get 'exhibits', to: 'exhibits#index'
  get 'exhibits/:id/:tab', to: 'exhibits#show'

  resources :series,
            only: [:index]

  resources :about,
            only: [:show]

  resources :transcripts,
            only: [:show]

  override_constraints = lambda do |req|
    path = req.params['path']
    path.match(/^[a-z0-9\/-]+$/) && !path.match(/^rails/)
  end

  get '/*path', to: 'override#show', constraints: override_constraints
end
