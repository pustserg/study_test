Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'bearers#index'

  resources :bearers, only: %i[index] do
    resources :stocks, except: %i[new edit]
  end
end
