Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: 'home#index'

  # Home and Index Routes
  get 'home/index'
  get 'index/frome'
  
  # Notification Routes
  get 'users/notifications', to: 'users#notifications'
  get 'notifications/unread', to: 'notifications#unread'
  get 'notifications/unread_count', to: 'notifications#unread_count'
  get 'notifications/index_with_participants_and_read_status', to: 'notifications#index_with_participants_and_read_status'
  patch 'notifications/:id/mark_as_read', to: 'notifications#mark_as_read'
  patch 'notifications/:id/read_status', to: 'notifications#read_status'
  get 'notifications/read', to: 'notifications#read_notifications'
  put '/notifications/mark_as_read', to: 'notifications#mark_as_read'
  
  
  # Resources
  resources :events, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'all'
      get 'my_events_with_participants'
      get 'selected_user_events'
    end
  end

  resources :calendars, only: [:index, :show, :create, :update, :destroy]
  resources :groups, only: [:index, :show, :create, :update, :destroy]
  resources :users, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'excerpt'
    end
  end

  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :participants, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'event_excerpt'
      get 'user_excerpt'
      post 'user_excerpt'
      get 'all'
      get 'participants_with_events'
      get 'events_with_participants'
    end
  end

  resources :user_visibilities, only: [:index, :update]

  # Devise specific routes
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_out', to: 'users/sessions#destroy'
  end
end
