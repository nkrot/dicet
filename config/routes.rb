Dicet::Application.routes.draw do
#  get "welcome/help"
#  get "welcome/index"
#  get "welcome/about"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # static pages
  match '/about', to: 'welcome#about', via: 'get'
  match '/help',  to: 'welcome#help',  via: 'get'

  resources :users
  match '/signup', to: 'users#new', via: 'get'

  match '/words/upload', to: 'words#upload', via: 'post'
  resources :words

#  match '/paradigms/dump', to: 'paradigms#dump', via: 'get'
  match '/paradigms/peek(/:status)', to: 'paradigms#peek', via: 'get'
  match '/paradigms/dump(/:status)', to: 'paradigms#dump', via: 'get'
  match '/paradigms/new_paradigm_of_type/:id', to: 'paradigms#new_paradigm_of_type', via: 'get'
  resources :paradigms

  resources :tasks, only: [:index, :update]
  match '/tasks/drop/:id', to: 'tasks#drop', via: 'put'
  match '/tasks/take/:id', to: 'tasks#take', via: 'put'

  resources :sessions, only: [:new, :create, :destroy]
  match '/signin',  to: 'sessions#new',     via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  match '/tags/upload', to: 'tags#upload', via: 'post'
  resources :tags,           only: [:index]

  resources :paradigm_types, only: [:index]

#  namespace :api, defaults: { format: :text } do
#    resources :paradigms, only: [:index]
#  end

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
