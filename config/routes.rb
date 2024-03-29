Rails.application.routes.draw do
  root to: 'home#index'
  blacklight_for :catalog # If I change this we get errors from the other pages.

  get '/treasuries/:title', to: 'treasuries#show'
  get '/miniseries/:title', to: 'treasuries#miniseries'

  # TODO: hardcoded due to misunderstanding of what a 'colleciton' means on OV
  get '/collections/alistair-cooke', to: 'treasuries#show'
  get '/collections/alistair-cooke-about', to: 'treasuries#bio'
  get '/collections/alistair-cooke-list', to: 'treasuries#list'
  get '/collections/alistair-cooke-clips', to: 'treasuries#clip'

  get 'collections', to: 'collections#index'
  get 'collections/:id(/:tab)', to: 'collections#show'



  
  match 'exhibits/zoom' => redirect('https://americanarchive.org/exhibits/zoom'), via: [:get]
  match 'exhibits/zoom/*path' => redirect('https://americanarchive.org/exhibits/zoom'), via: [:get]
  get 'exhibits', to: 'exhibits#index'
  get 'exhibits/:id(/:tab)', to: 'exhibits#show'

  resources :series,
            only: [:index]

  resources :about,
            only: [:show]

  resources :transcripts,
            only: [:show]

  resources :embed,
            only: [:show]

  get '/embed/card/:id', to: 'embed#card'

  resources :sitemap,
            only: [:index]

  resources :oai,
            only: [:index]

  get 'robots', to: 'robots#show'

  # map error routes directly to error partials
  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'

  override_constraints = lambda do |req|
    !req.params['path'].to_s.match(/^rails/)
  end

  get '/plain/*path', to: 'plain_override#show', constraints: override_constraints
  get '/*path', to: 'override#show', constraints: override_constraints
end
