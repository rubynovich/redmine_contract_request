# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :contract_requests
get 'projects/:project_id/contract_requests' => 'contract_requests#index'
