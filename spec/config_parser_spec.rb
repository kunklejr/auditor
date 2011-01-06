require File.dirname(__FILE__) + '/spec_helper'
require 'auditor'

describe Auditor::ConfigParser do
  
  describe 'Configuration' do
    it "should parse actions and options from a config array" do
      config = Auditor::ConfigParser.extract_config([:create, 'update', {:only => :username}])
      config.should_not be_nil
      config.should have(2).items
      config[0].should =~ [:create, :update]
      config[1].should == {:only => ["username"], :except => []}
    end
  
    it "should parse actions and options from a config array when options are absent" do
      config = Auditor::ConfigParser.extract_config([:create, 'update'])
      config.should_not be_nil
      config.should have(2).items
      config[0].should =~ [:create, :update]
      config[1].should == {:only => [], :except => []}
    end
    
    it "should parse actions" do
      config = Auditor::ConfigParser.extract_config([:create])
      config.should_not be_nil
      config.should have(2).items
      config[0].should =~ [:create]
      config[1].should == {:only => [], :except => []}
    end

  end
  
  describe 'Configuration Validation' do
    it "should raise a Auditor::Error if no action is specified" do
      lambda {
        Auditor::ConfigParser.instance_eval { validate_config([], {}) }
      }.should raise_error(Auditor::Error)
    end
    
    it "should raise a Auditor::Error if an invalid action is specified" do
      lambda {
        Auditor::ConfigParser.instance_eval { validate_config([:create, :udate], {}) }
      }.should raise_error(Auditor::Error)
    end
    
    it "should raise a Auditor::Error if both the except and only options are specified" do
      lambda {
        Auditor::ConfigParser.instance_eval { validate_config([:find], {:except => :ssn, :only => :username}) }
      }.should raise_error(Auditor::Error)
    end
  end
  
end