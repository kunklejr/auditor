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
      return true if auditing_disabled?
      user = Auditor::User.current_user

      audit = Audit.new
      audit.auditable = model
      audit.user = user
      audit.audited_changes = prepare_changes(model.changes)
      audit.action = action.to_s
      audit.comment = @blk.call(model, user) if @blk

      # TODO: Make the bang a configurable option
      audit.save!
    end

    def prepare_changes(changes)
      chg = changes.dup
      chg = chg.delete_if { |key, value| @options[:except].include?(key) } unless @options[:except].empty?
      chg = chg.delete_if { |key, value| !@options[:only].include?(key) } unless @options[:only].empty?
      chg.empty? ? nil : chg
    end

  end
end
