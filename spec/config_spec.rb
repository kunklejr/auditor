require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/config'

describe Auditor::Config do
  
  describe 'Configuration' do
    it "should parse actions and options from a config array" do
      config = Auditor::Config.new([:create, 'update', {:only => :username}])
      config.actions.should_not be_nil
      config.options.should_not be_nil
      config.actions.should have(2).items
      config.actions.should =~ [:create, :update]
      config.options.should == {:only => ["username"], :except => []}
    end

    it "should parse actions and options from a config array when options are absent" do
      config = Auditor::Config.new([:create, 'update'])
      config.actions.should_not be_nil
      config.actions.should have(2).items
      config.actions.should =~ [:create, :update]
      config.options.should == {:only => [], :except => []}
    end

    it "should parse actions" do
      config = Auditor::Config.new([:create])
      config.actions.should_not be_nil
      config.actions.should have(2).items
      config.actions.should =~ [:create]
      config.options.should == {:only => [], :except => []}
    end

  end

  describe 'Configuration Validation' do
    it "should raise a Auditor::Error if no action is specified" do
      lambda {
        Auditor::Config.instance_eval { validate_actions([]) }
      }.should raise_error(Auditor::Error)
    end

    it "should raise a Auditor::Error if an invalid action is specified" do
      lambda {
        Auditor::Config.instance_eval { validate_actions([:create, :udate]) }
      }.should raise_error(Auditor::Error)
    end

  end

end
