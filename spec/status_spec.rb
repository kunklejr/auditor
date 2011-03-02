require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/status'

describe Auditor::Status do
  it "should be enabled if set to enabled" do
    obj = Class.new { include Auditor::Status }.new
    obj.enable_auditing
    obj.should be_auditing_enabled
    obj.should_not be_auditing_disabled
  end

  it "should be disabled if set to disabled" do
    obj = Class.new { include Auditor::Status }.new
    obj.disable_auditing
    obj.should_not be_auditing_enabled
    obj.should be_auditing_disabled
  end
end
