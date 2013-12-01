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
  match '/todo',  to: 'welcome#todo',  via: 'get'

  resources :users do
    resources :tasks, only: :index do
      collection do
        match :ready, via: :get
      end
    end
  end
  match '/signup', to: 'users#new', via: 'get'

  resources :tasks, only: :index do
    collection do
      match :ready, via: :get
    end
  end
  match '/tasks/drop/:id', to: 'tasks#drop',     via: 'put'
  match '/tasks/take/:id', to: 'tasks#take',     via: 'put'
  match '/tasks/generate', to: 'tasks#generate', via: 'get'

  match '/words/upload', to: 'words#upload', via: 'post'
  resources :words

#  match '/paradigms/dump', to: 'paradigms#dump', via: 'get'
  match '/paradigms/peek(/:status)', to: 'paradigms#peek', via: 'get'
  match '/paradigms/dump(/:status)', to: 'paradigms#dump', via: 'get'
  match '/paradigms/new_paradigm_of_type/:id', to: 'paradigms#new_paradigm_of_type', via: 'get'
  match '/paradigms/add_conversions', to: 'paradigms#add_conversions', via: ['patch', 'post']
  resources :paradigms

  resources :sessions, only: [:new, :create, :destroy]
  match '/signin',  to: 'sessions#new',     via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  match '/tags/upload', to: 'tags#upload', via: 'post'
  resources :tags,           only: [:index]

  match '/paradigm_types/upload', to: 'paradigm_types#upload', via: 'post'
  resources :paradigm_types, only: [:index]

  match '/sentences/upload', to: 'sentences#upload', via: 'post'
  match '/sentences/search', to: 'sentences#search', via: 'get'
  resources :sentences, only: [:index]

  resources :documents, only: [:index, :show]

  match '/tokens/:unknown', to: 'tokens#index', via: 'get' # TODO: as: :unknown_tokens is not enough, requires writing unknown_tokens_path(:unknown), while I want just 'unknown_tokens_path'
  match '/tokens/take/:id', to: 'tokens#take',  via: 'get'
  match '/tokens/drop/:id', to: 'tokens#drop',  via: 'get'
  match '/tokens/setbad/:id',  to: 'tokens#setbad',  via: 'get'
  match '/tokens/setgood/:id', to: 'tokens#setgood', via: 'get'
  resources :tokens, only: [:index]

#  match '/statistics/recompute', to: 'statistics#recompute', via: 'get'

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
