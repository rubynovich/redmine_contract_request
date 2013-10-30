Redmine::Plugin.register :redmine_contract_request do
  name 'Contract Request'
  author 'Roman Shipiev'
  description 'Contract request for Redmine'
  version '0.0.2'
  url 'http://bitbucket.org/rubynovich/redmine_contract_request'
  author_url 'http://roman.shipiev.me'

  settings :default => {
                       :duration => 7
                     },
         :partial => 'contract_requests/settings'


  menu :project_menu, :contract_requests, {:controller => :contract_requests, :action => :index}, :caption => :label_contract_request_plural, :param => :project_id, :if => Proc.new{ User.current.contract_request_manager? }

  Redmine::MenuManager.map :top_menu do |menu| 

    # parent = menu.exists?(:public_intercourse) ? :public_intercourse : :top_menu
    parent = menu.exists?(:public_intercourse) ? :projects : :top_menu

    menu.push( :contract_requests, 
               {:controller => :contract_requests, :action => :index}, 
               { :parent => parent,            
                 :caption => :label_contract_request_plural, 
                 :if => Proc.new{User.current.contract_request_manager?}
               })
    
  end

  project_module :contract_request do
    permission :view_contract_request,   :contract_requests => [:index, :show]
    permission :new_contract_request,    :contract_requests => [:new, :create, :edit, :update]
    permission :edit_contract_request,   :contract_requests => [:edit, :update]
    permission :delete_contract_request, :contract_requests => [:destroy]
  end
end

Rails.configuration.to_prepare do
  [:issue, :user].each do |cl|
    require "contract_request_#{cl}_patch"
  end

  require_dependency 'contract_request'
  require 'time_period_scope'

  [
    [Issue, ContractRequestPlugin::IssuePatch],
    [User, ContractRequestPlugin::UserPatch],
    [ContractRequest, TimePeriodScope]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
