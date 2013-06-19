Redmine::Plugin.register :redmine_contract_request do
  name 'Contract Request'
  author 'Roman Shipiev'
  description 'Contract request for Redmine'
  version '0.0.1'
  url 'http://bitbucket.org/rubynovich/redmine_contract_request'
  author_url 'http://roman.shipiev.me'

  settings :default => {
                       :duration => 7
                     },
         :partial => 'contract_requests/settings'

  menu :top_menu, :contract_request, {:controller => :contract_requests, :action => :index}, :caption => :label_contract_request_plural, :if => Proc.new{true || User.current.contract_request_manager?}
  menu :project_menu, :contract_request, {:controller => :contract_requests, :action => :index}, :caption => :label_contract_request_plural, :param => :project_id, :if => Proc.new{true || User.current.contract_request_manager?}

  project_module :contract_request_module do
  end
end

Rails.configuration.to_prepare do
  [:issue, :user].each do |cl|
    require "contract_request_#{cl}_patch"
  end

  [
    [Issue, ContractRequestPlugin::IssuePatch],
    [User, ContractRequestPlugin::UserPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
