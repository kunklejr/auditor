require 'auditor/audit'
require 'auditor/auditable'

ActiveRecord::Base.send :include, Auditor::Auditable

if defined?(ActionController) and defined?(ActionController::Base)

  require 'auditor/user'

  ActionController::Base.class_eval do
    before_filter do
      Auditor::User.current_user = self.current_user if self.respond_to?(:current_user)
    end
  end

end

