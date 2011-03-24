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

  it "should allow auditing as a specified user for a block of code" do
    obj = Class.new { include Auditor::Status }.new
    user1 = "user1"
    user2 = "user2"
    Auditor::User.current_user = user1

    obj.audit_as(user2) { Auditor::User.current_user.should == user2 }
    Auditor::User.current_user.should == user1
  end

  it "should allow a block of code to be executed with auditing disabled" do
    obj = Class.new { include Auditor::Status }.new
    obj.enable_auditing
    obj.should be_auditing_enabled
    obj.without_auditing { obj.should be_auditing_disabled }
    obj.should be_auditing_enabled
  end

  it "should allow a block of code to be executed with auditing enabled" do
    obj = Class.new { include Auditor::Status }.new
    obj.disable_auditing
    obj.should be_auditing_disabled
    obj.with_auditing { obj.should be_auditing_enabled }
    obj.should be_auditing_disabled
  end
end
