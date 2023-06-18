Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  } 

  get 'home/index'
  get '/index/frome'
  post "/sign_in", to: "sessions#create"
  
  root to: 'home#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  resources :events, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'all' # /events/all
      get 'index_with_participants' # /events/index_with_participants 
    end
  end
  resources :calendars, only: [:index, :show, :create, :update, :destroy]
  resources :groups, only: [:index, :show, :create, :update, :destroy]
  resources :users, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'excerpt' # /users/excerpt
    end
  end

  resources :password_resets, only: [:new, :create, :edit, :update]
  #Techpit Add
  resources :participants, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'event_excerpt' # /participants/event_excerpt
      get 'user_excerpt' # /participants/user_excerpt
      post 'user_excerpt' # /participants/user_excerpt
      get 'events_with_participants' # /participants/events_with_participants
      get 'all' # /participants/all
    end
  end

  resources :user_visibilities, only: [:index, :update]

  devise_scope :user do
    get "sign_in", :to => "users/sessions#new"
    post   '/sign_in',   to: 'sessions#create'
    get "sign_out", :to => "users/sessions#destroy" 
  end

end
