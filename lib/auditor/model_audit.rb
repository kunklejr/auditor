require 'auditor/thread_status'
require 'auditor/config_parser'
require 'auditor/recorder'

module Auditor
  module ModelAudit
    
    def self.included(base)
      base.extend ClassMethods
    end
  
    # ActiveRecord won't call the after_find handler unless it see's a specific after_find method defined
    def after_find; end
  
    def auditor_disabled?
      Auditor::ThreadStatus.disabled? || @auditor_disabled
    end
    
    module ClassMethods
      def audit(*args, &blk)
        actions, options = Auditor::ConfigParser.extract_config(args)
      
        actions.each do |action|
          unless action.to_sym == :find
            callback = "auditor_before_#{action}"
            define_method(callback) do
              @auditor_auditor = Auditor::Recorder.new(action, self, options, &blk)
              @auditor_auditor.audit_before unless auditor_disabled?
              true
            end 
            send "before_#{action}".to_sym, callback
          end
          
          callback = "auditor_after_#{action}"
          define_method(callback) do
            @auditor_auditor = Auditor::Recorder.new(action, self, options, &blk) if action.to_sym == :find
            @auditor_auditor.audit_after unless auditor_disabled?
            true
          end
          send "after_#{action}".to_sym, callback
          
        end
      end
    end
    
  end
end