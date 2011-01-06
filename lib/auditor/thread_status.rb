require 'auditor/thread_local'

module Auditor
  module ThreadStatus
    
    def self.enabled?
      status
    end
    
    def self.disabled?
      !status
    end
    
    def self.enable
      set_status true
    end
    
    def self.disable
      set_status false
    end
    
    private
      def self.status
        @status = Auditor::ThreadLocal.new(true) if @status.nil?
        @status.get
      end
      
      def self.set_status(status)
        @status = Auditor::ThreadLocal.new(true) if @status.nil?
        @status.set status
      end
    
  end
end