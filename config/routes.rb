Rails.application.routes.draw do
  resources :reports, except: %i[update] do
    member do
      get 'data/:file', to: 'reports#data', as: 'data'
      post 'codeql', to: 'reports#collect_codeql'
    end
  end
  resources :datasets, only: %i[show]
  resources :report_files, only: %i[show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # post "/users", to: "users#create"
  get "/users/me", to: "users#me"
  put "/users/update", to: "users#update"
  put "/users/change_password", to: "users#change_password"

  post "/auth/register", to: "auth#register"
  post "/auth/login", to: "auth#login"

  # Defines the root path route ("/")
  # root "articles#index"
end
