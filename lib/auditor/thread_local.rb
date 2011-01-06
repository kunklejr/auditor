module Auditor
  class ThreadLocal
    
    def initialize(initial_value)
      @thread_symbol = "#{rand}#{Time.now.to_f}"
      set initial_value
    end
    
    def set(value)
      Thread.current[@thread_symbol] = value
    end
    
    def get
      Thread.current[@thread_symbol]
    end
    
  end
end