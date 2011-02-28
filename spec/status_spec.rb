require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/status'

describe Auditor::Status do
  include Auditor::Status

  it "should be enabled if set to enabled" do
    enable_auditing
    auditing.should be_enabled
    auditing.should_not be_disabled
  end
  
  it "should be disabled if set to disabled" do
    disable_auditing
    auditing.should_not be_enabled
    auditing.should be_disabled
  end
end
