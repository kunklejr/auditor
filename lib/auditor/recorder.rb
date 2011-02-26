require 'auditor/status'

module Auditor
  class Recorder
    include Status

    def initialize(options, &blk)
      @options = options
      @blk = blk
    end

    def after_find(model)
      @audit = Audit.new
    end

  private

    def user
      Auditor::User.current_user
    end

    def audit_before(model)
      @audit = Audit.new(:audited_changes => prepare_changes(model.changes))
    end

    def audit_after(model, action)
      return true if auditor_disabled?

      @audit.attributes = {
        :auditable_id => model.id,
        :auditable_type => model.class.to_s,
        :user_id => user.id,
        :user_type => user.class.to_s,
        :action => action.to_s
      }

      @audit.auditable_version = model.version if model.respond_to?(:version)
      @audit.comment = @blk.call(model, user) if @blk

      # TODO: Make the bang a configurable option
      @audit.save!
    end

    def prepare_changes(edits)
      chg = changes.dup
      chg = chg.delete_if { |key, value| @options[:except].include?(key) } unless @options[:except].empty?
      chg = chg.delete_if { |key, value| !@options[:only].include?(key) } unless @options[:only].empty?
      chg.empty? ? nil : chg
    end

  public

    def self.after_callback(action)
      define_method("after_#{action}") do |model|
        audit_after(model, action)
      end
    end

    alias :before_create :audit_before
    alias :before_update :audit_before
    alias :before_destroy :audit_before

    after_callback(:create)
    after_callback(:update)
    after_callback(:destroy)
  end
end
