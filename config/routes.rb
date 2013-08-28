Ldg::Application.routes.draw do
  match '/', to: 'restaurants#index'
  match '/search',  to: 'restaurants#search'
  match '/timeline',  to: 'restaurants#timeline'
end
