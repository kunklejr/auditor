require 'auditor/status'

module Auditor
  class Recorder
    include Status

    def initialize(options, &blk)
      @options = options
      @blk = blk
    end

    [:create, :find, :update, :destroy].each do |action|
      define_method("after_#{action}") do |model|
        audit(model, action)
      end
    end

  private

    def audit(model, action)
      return nil if auditing_disabled?
      user = Auditor::User.current_user

      audit = Audit.new
      audit.auditable_id = model.id
      audit.auditable_type = model.class.name
      audit.audited_changes = prepare_changes(model.changes) if changes_available?(action)
      audit.action = action
      audit.comment = @blk.call(model, user, action) if @blk

      without_auditing do
        owner = @options[:on] ? model.send(@options[:on].to_sym) : model
        audit.owner_id = owner.id
        audit.owner_type = owner.class.name
      end

      @options[:fail_on_error] ? audit.save! : audit.save
    end

    def prepare_changes(changes)
      chg = changes.dup
      chg = chg.delete_if { |key, value| @options[:except].include?(key) } unless @options[:except].blank?
      chg = chg.delete_if { |key, value| !@options[:only].include?(key) } unless @options[:only].blank?
      chg.empty? ? nil : chg
    end

    def changes_available?(action)
      [:create, :update].include?(action)
    end

  end
end
