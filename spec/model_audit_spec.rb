require File.dirname(__FILE__) + '/spec_helper'
require 'auditor'

describe Auditor::ModelAudit do
  
  before(:each) do
    Auditor::User.current_user = (Class.new do
      def id; 1 end
    end).new
  end
  
  it 'should audit find' do
    c = new_model_class.instance_eval { audit(:find); self }
    verify_standard_audits(c.new, :find)
  end
  
  it 'should audit create' do
    c = new_model_class.instance_eval { audit(:create); self }
    verify_standard_audits(c.new, :create)
  end
  
  it 'should audit update' do
    c = new_model_class.instance_eval { audit(:update); self }
    verify_standard_audits(c.new, :update)
  end
  
  it 'should audit destroy' do
    c = new_model_class.instance_eval { audit(:destroy); self }
    verify_standard_audits(c.new, :destroy)
  end
  
  it 'should allow multiple actions to be specified with one audit statment' do
    c = new_model_class.instance_eval { audit(:create, :update); self }
    verify_standard_audits(c.new, :create, :update)
    
    c = new_model_class.instance_eval { audit(:create, :update, :destroy); self }
    verify_standard_audits(c.new, :create, :update, :destroy)
    
    c = new_model_class.instance_eval { audit(:create, :update, :destroy, :find); self }
    verify_standard_audits(c.new, :create, :update, :destroy, :find)
  end
  
  def verify_standard_audits(instance, *audited_callbacks)
    audited_callbacks.each do |action|
      mock_auditor = mock('auditor')
      Auditor::Recorder.should_receive(:new).and_return(mock_auditor)
      mock_auditor.should_receive(:audit_before) unless action == :find
      mock_auditor.should_receive(:audit_after)
      instance.send action
    end
  end
  
  def new_model_class
    Class.new(ActiveRecordMock) do
      include Auditor::ModelAudit
    end
  end
  
  class ActiveRecordMock
    def id; 1 end
    
    [:create, :update, :destroy, :find].each do |action|
      define_method(action) do
        send "before_#{action}".to_sym unless action == :find
        send "after_#{action}".to_sym
      end
      
      metaclass = class << self; self end
      metaclass.instance_eval do
        unless action == :find
          define_method("before_#{action}") do |method|
            define_method("before_#{action}") { send method }
          end
        end
        define_method("after_#{action}") do |method|
          define_method("after_#{action}") { send method }
        end
      end
    end
    
  end
  
end