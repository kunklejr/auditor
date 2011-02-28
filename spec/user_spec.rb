require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/user'

describe Auditor::User do
  it "should return the same user that's set on the same thread" do
    user = "user"
    Auditor::User.current_user = user
    Auditor::User.current_user.should == user
  end

  it "should not return the same user from a different thread" do
    user = "user"
    user2 = "user2"

    Auditor::User.current_user = user

    Thread.new do
      Auditor::User.current_user.should be_nil
      Auditor::User.current_user = user2
      Auditor::User.current_user.should == user2
    end

    Auditor::User.current_user.should == user
  end
end
