require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/thread_local'

describe Auditor::ThreadLocal do
  it "should properly set and get thread-local variables" do
    val = "val"
    tl = Auditor::ThreadLocal.new(val)
    tl.get.should == val
    
    val2 = "val2"
    tl.set val2
    tl.get.should == val2
  end
end