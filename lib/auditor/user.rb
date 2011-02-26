module Auditor
  module User

    def current_user
      Thread.current[:auditor_user]
    end

    def current_user=(user)
      Thread.current[:auditor_user] = user
    end

    module_function :current_user, :current_user=

  end
end
