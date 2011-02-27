require 'auditor/audit'
require 'auditor/status'
require 'auditor/config'
require 'auditor/recorder'
require 'auditor/user'

module Auditor
  include Status

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def audit(*args, &blk)
      config = Config.new(args)
      config.actions.each do |action|
        send "after_#{action}", Recorder.new(config.options, &blk)
      end
    end
  end
end

ActiveRecord::Base.send :include, Auditor
