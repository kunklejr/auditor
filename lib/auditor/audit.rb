require 'active_record'

class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :user, :polymorphic => true

  validates_presence_of :auditable_id, :auditable_type, :user_id, :user_type, :action

  serialize :audited_changes
end
