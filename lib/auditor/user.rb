module Auditor
  module User

    def current_user
      RequestStore.store[:auditor_user]
    end

    def current_user=(user)
      RequestStore.store[:auditor_user] = user
    end

    module_function :current_user, :current_user=

  end
end
