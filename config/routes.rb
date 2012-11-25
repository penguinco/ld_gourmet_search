Ldg::Application.routes.draw do
  match '/', to: 'restaurants#index'
  match '/search',  to: 'restaurants#search'
  match '/review_search',  to: 'restaurants#review_search'
end
