require 'active_record'
require 'request_store'
require 'auditor/config'

class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :owner, :polymorphic => true
  belongs_to :user, :polymorphic => true

  before_create :set_version_number
  before_create :set_user

  serialize :audited_changes

  default_scope order(:version, :created_at)
  scope :modifying, lambda {
    where( [
      'audited_changes is not ? and audited_changes not like ?',
      nil,        # ActiveRecord 3.0
      nil.to_yaml # ActiveRecord 3.1
    ] )
  }
  scope :trail, lambda { |audit|
    where('auditable_id = ? and auditable_type = ? and version <= ?',
    audit.auditable_id, audit.auditable_type, audit.version)
  }

  def attribute_snapshot
    attributes = {}.with_indifferent_access
    self.class.modifying.trail(self).each do |predecessor|
      attributes.merge!(predecessor.new_attributes)
    end
    attributes
  end

protected

  # Returns a hash of the changed attributes with the new values
  def new_attributes
    (audited_changes || {}).inject({}.with_indifferent_access) do |attrs,(attr,values)|
      attrs[attr] = values.is_a?(Array) ? values.last : values
      attrs
    end
  end

private

  def set_version_number
    max = self.class.where(
      :auditable_id => auditable_id,
      :auditable_type => auditable_type
    ).maximum(:version) || 0

    self.version = self.audited_changes == nil ? max : max + 1
  end

  def set_user
    self.user = Auditor::User.current_user if self.user_id.nil?
  end

end
