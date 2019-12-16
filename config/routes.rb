Rails.application.routes.draw do
  resources :zillow_locations
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	resources :projects
	resources :products
	post '/projects/zillow-flow', to: 'projects#zillow_flow'

	get '/myprofile', to: 'user_profile#show'

	get '/myactivity', to: 'projects#my_activity'

	namespace :api, constraints: { format: 'json' } do
        mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          registrations:  'users/registrations'
        }
  end

  resources :wishlists
  post '/wishlists/add-to-wishlist', to: 'wishlists#add_to_wishlist'
  post '/wishlists/remove-from-wishlist', to: 'wishlists#remove_from_wishlist'

  resources :tasks

end
