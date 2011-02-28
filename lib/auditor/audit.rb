require 'active_record'
require 'auditor/config'

class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :user, :polymorphic => true

  validates_presence_of :auditable_id, :auditable_type, :user_id, :user_type, :action
  validates_inclusion_of :action, :in => Auditor::Config.valid_actions

  before_create :set_version_number

  serialize :audited_changes

  default_scope order(:version, :created_at)
  scope :modifying, lambda { where('action in (?)', Auditor::Config.modifying_actions) }
  scope :predecessors, lambda { |audit|
    where('auditable_id = ? and auditable_type = ? and version <= ?',
    audit.auditable_id, audit.auditable_type, audit.version) 
  }

  def attribute_snapshot
    attributes = {}.with_indifferent_access
    self.class.modifying.predecessors(self).each do |predecessor|
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

    self.version = Auditor::Config.modifying_actions.include?(self.action.to_sym) ? max + 1 : max
  end

end
