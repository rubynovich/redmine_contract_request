require_dependency 'user'

module ContractRequestPlugin
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :contract_requests, :foreign_key => :author_id, :dependent => :destroy
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def contract_request_manager?
        begin
          principal = Principal.find(Setting[:plugin_redmine_contract_request][:principal_id])
          if principal.is_a?(Group)
            principal.users.include?(self)
          elsif principal.is_a?(User)
            principal == self
          end
        rescue
          nil
        end
      end
    end
  end
end
