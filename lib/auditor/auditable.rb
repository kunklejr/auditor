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

      def audit!(*args, &blk)
        if args.last.kind_of?(Hash)
          args.last[:fail_on_error] = true
        else
          args << { :fail_on_error => true }
        end

        audit(*args, &blk)
      end
    end

    module InstanceMethods
      def attributes_at(date_or_time)
        audits.where('created_at <= ?', date_or_time).last.attribute_snapshot
      end
    end

  end
end
