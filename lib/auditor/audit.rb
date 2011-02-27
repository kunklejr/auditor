require 'active_record'

class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :user, :polymorphic => true

  validates_presence_of :auditable_id, :auditable_type, :user_id, :user_type, :action

  before_create :set_version_number

  serialize :audited_changes

private

  def set_version_number
    max = self.class.maximum(:version).where(:auditable_id => auditable_id, :auditable_type => auditable_type) || 0
    self.version = max + 1
  end
end
