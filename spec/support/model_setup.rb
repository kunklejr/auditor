class User < ActiveRecord::Base; end
class Model < ActiveRecord::Base
  belongs_to :user
end
