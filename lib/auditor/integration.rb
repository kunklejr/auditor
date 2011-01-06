require 'auditor/thread_status'

module Auditor
  module Integration
    
    def without_auditor
      previously_disabled = auditor_disabled?
      disable_auditor
      
      begin
        result = yield if block_given?
      ensure
        enable_auditor unless previously_disabled
      end
      
      result
    end
    
    def with_auditor
      previously_disabled = auditor_disabled?
      enable_auditor
      
      begin
        result = yield if block_given?
      ensure
        disable_auditor if previously_disabled
      end
      
      result
    end
    
    def disable_auditor
      Auditor::ThreadStatus.disable
    end
    
    def enable_auditor
      Auditor::ThreadStatus.enable
    end
    
    def auditor_disabled?
      Auditor::ThreadStatus.disabled?
    end
    
    def auditor_enabled?
      Auditor::ThreadStatus.enabled?
    end
    
  end
end