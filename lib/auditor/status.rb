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
      previously_disabled = auditing_disabled?

      begin
        disable_auditing
        result = yield if block_given?
      ensure
        enable_auditing unless previously_disabled
      end

      result
    end

    def with_auditing
      previously_disabled = auditing_disabled?

      begin
        enable_auditing
        result = yield if block_given?
      ensure
        disable_auditing if previously_disabled
      end

      result
    end

    def audit_as(user)
      previous_user = Auditor::User.current_user

      begin
        Auditor::User.current_user = user
        result = yield if block_given?
      ensure
        Auditor::User.current_user = previous_user
      end

      result
    end

  end
end
