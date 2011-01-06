require 'active_record'

class Audit < ActiveRecord::Base
  validates_presence_of :auditable_id, :auditable_type, :user_id, :user_type, :action
  serialize :edits
end
