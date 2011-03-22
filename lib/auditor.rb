require 'auditor/audit'
require 'auditor/auditable'

module Auditor
  class Error < StandardError; end
end

ActiveRecord::Base.send :include, Auditor::Auditable

if defined?(ActionController) and defined?(ActionController::Base)

  require 'auditor/user'

  ActionController::Base.class_eval do
    before_filter do |c|
      Auditor::User.current_user = c.send(:current_user) if c.respond_to?(:current_user)
    end
  end

end

