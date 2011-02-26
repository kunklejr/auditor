require 'active_record'

module Auditor
  class Audit < ActiveRecord::Base
    table_name :audits
    validates_presence_of :auditable_id, :auditable_type, :user_id, :user_type, :action
    serialize :edits
  end
end
