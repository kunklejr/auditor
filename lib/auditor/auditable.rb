require 'auditor/status'
require 'auditor/config'
require 'auditor/recorder'

module Auditor
  module Auditable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def audit(*args, &blk)
        unless self.included_modules.include?(Auditor::Auditable::InstanceMethods)
          include InstanceMethods
          include Auditor::Status unless self.included_modules.include?(Auditor::Status)
          has_many :audits, :as => :auditable
        end

        config = Auditor::Config.new(args)
        config.actions.each do |action|
          send "after_#{action}", Auditor::Recorder.new(config.options, &blk)
        end
      end
    end

    module InstanceMethods

    end
  end
end
