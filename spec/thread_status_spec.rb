require File.dirname(__FILE__) + '/spec_helper'
require 'auditor'

describe Auditor::ThreadStatus do
  it "should be enabled if set to enabled" do
    Auditor::ThreadStatus.enable
    Auditor::ThreadStatus.should be_enabled
    Auditor::ThreadStatus.should_not be_disabled
  end
  
  it "should be disabled if set to disabled" do
    Auditor::ThreadStatus.disable
    Auditor::ThreadStatus.should_not be_enabled
    Auditor::ThreadStatus.should be_disabled
  end
end