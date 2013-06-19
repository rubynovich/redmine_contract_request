require_dependency 'issue'
require_dependency 'issue_status'

module ContractRequestPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        has_one :contract_request
      end

    end

    module ClassMethods

    end

    module InstanceMethods

    end
  end
end
