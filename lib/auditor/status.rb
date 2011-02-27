module Auditor
  module Status

    def auditing_disabled?
      Thread.current[:auditor_disabled] == true
    end

    def auditing_enabled?
      Thread.current[:auditor_disabled] == false
    end

    def disable_auditing
      Thread.current[:auditor_disabled] = true
    end

    def enable_auditing
      Thread.current[:auditor_disabled] = false
    end

    def without_auditing
      previously_disabled = auditor_disabled?

      begin
        disable_auditor
        result = yield if block_given?
      ensure
        enable_auditor unless previously_disabled
      end

      result
    end

    def with_auditing
      previously_disabled = auditor_disabled?

      begin
        enable_auditor
        result = yield if block_given?
      ensure
        disable_auditor if previously_disabled
      end

      result
    end

  end
end
