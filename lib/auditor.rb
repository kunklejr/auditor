require 'auditor/audit'
require 'auditor/status'
require 'auditor/config_parser'
require 'auditor/recorder'
require 'auditor/user'

module Auditor
  include Status

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def audit(*args, &blk)
      actions, options = ConfigParser.extract_config(args)

      actions.each do |action|
        recorder = Recorder.new(options, &blk)
        send "before_#{action}", recorder unless action.to_sym == :find
        send "after_#{action}", recorder
      end
    end
  end
end

