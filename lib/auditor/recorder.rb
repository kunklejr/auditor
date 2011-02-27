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
      return true if auditor_disabled?
      user = Auditor::User.current_user

      @audit = Audit.new({
        :auditable_id => model.id,
        :auditable_type => model.class.to_s,
        :audited_changes => prepare_changes(model.changes),
        :user_id => user.id,
        :user_type => user.class.to_s,
        :action => action.to_s
      })

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

  end
end
