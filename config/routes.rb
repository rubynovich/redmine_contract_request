# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :contract_requests, :only => [:index, :new]
end

resources :contract_requests, :except => [:new]
#get 'projects/:project_id/contract_requests' => 'contract_requests#index'
