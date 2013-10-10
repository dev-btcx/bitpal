BitcoinApp::Application.routes.draw do
  match '/pay' => 'orders#new'
  match '/orders/check_new' => 'orders#check_new'
  match '/orders/check_pending' => 'orders#check_pending'
  match '/orders/check_expired' => 'orders#check_expired'
  match '/orders/:id/refund' => 'refunds#new'

  resources :merchants
  resources :payments
  resources :orders
  resources :withdraws
  resources :refunds
  resources :sessions, :only => [:new, :create, :destroy]

  match '/registration' => 'pages#registration'
  match '/example' => 'pages#example'
  match '/about' => 'pages#about'

  match '/merchants/:id/orders' => 'orders#index'
  match '/merchants/:id/withdraws' => 'withdraws#index'
  match '/signout' => 'sessions#destroy'
  match '/signin' => 'sessions#new'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
