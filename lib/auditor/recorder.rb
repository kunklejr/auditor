require 'auditor/user'

module Auditor
  class Recorder
    
    def initialize(action, model, options, &blk)
      @action, @model, @options, @blk = action.to_sym, model, options, blk
    end
      
    def audit_before
      @audit = Audit.new(:edits => prepare_edits(@model.changes, @options))
    end

    def audit_after
      @audit ||= Audit.new
      
      @audit.attributes = {
        :auditable_id => @model.id,
        :auditable_type => @model.class.to_s,
        :user_id => user.id,
        :user_type => user.class.to_s,
        :action => @action.to_s
      }
      
      @audit.auditable_version = @model.version if @model.respond_to? :version
      @audit.message = @blk.call(@model, user) if @blk

      @audit.save  
    end
    
    private
      def user
        Auditor::User.current_user
      end
      
      def prepare_edits(changes, options)
        chg = changes.dup
        chg = chg.delete_if { |key, value| options[:except].include? key } unless options[:except].empty?
        chg = chg.delete_if { |key, value| !options[:only].include? key } unless options[:only].empty?
        chg.empty? ? nil : chg
      end
    
  end
end