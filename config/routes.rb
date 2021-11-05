Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "game#index"
  get 'start', to: 'game#start'
  post 'start', to: 'game#start'
  get 'restart', to: 'game#restart'

  get 'stats', to: "game#stats"
end
