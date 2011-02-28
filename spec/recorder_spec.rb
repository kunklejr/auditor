require File.dirname(__FILE__) + '/spec_helper'
require 'auditor'

describe Auditor::Recorder do
  before(:each) do
    @user = Auditor::User.current_user = new_model(7)
  end

  it 'should create and save a new audit record' do
    model = new_model(42, {'first_name' => ['old','new']})

    auditor = Auditor::Recorder.new(:create, model, {:except => [], :only => []})  { |m, u| "Model: #{m.id} User: #{u.id}" }

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.action.should == 'create'
    audit.audited_changes.to_a.should =~ [['first_name', ['old', 'new']]]
    audit.auditable_id.should == 42
    audit.auditable_type.should == model.class.to_s
    audit.user_id.should == @user.id
    audit.user_type.should == @user.class.to_s
    audit.comment.should == 'Model: 42 User: 7'
  end

  it 'should capture the new id of a created record' do
    model = new_model

    auditor = Auditor::Recorder.new(:create, model, {:except => [], :only => []})

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.auditable_id.should == 42
    audit.auditable_type.should == model.class.to_s
  end

  it 'should set comment details to nil if they are not given' do
    model = new_model
    auditor = Auditor::Recorder.new(:create, model, {:except => [], :only => []})

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.comment.should be_nil
  end

  it 'should not save change details for excepted attributes' do
    model = new_model(42, {'first_name' => ['old','new'], 'last_name' => ['old','new']})

    auditor = Auditor::Recorder.new(:create, model, {:except => ['last_name'], :only => []})

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.audited_changes.to_a.should =~ [['first_name', ['old', 'new']]]    
  end

  it 'should only save change details for onlyed attributes' do
    model = new_model(42, {'first_name' => ['old','new'], 'last_name' => ['old','new']})

    auditor = Auditor::Recorder.new(:create, model, {:except => [], :only => ['last_name']})

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.audited_changes.to_a.should =~ [['last_name', ['old', 'new']]]    
  end

  it 'should not save attributes listed in both the only and except options' do
    model = new_model(42, {'first_name' => ['old','new'], 'last_name' => ['old','new']})

    auditor = Auditor::Recorder.new(:create, model, {:except => ['last_name'], :only => ['last_name']})

    audit = do_callbacks(auditor, model)

    audit.saved.should be_true
    audit.audited_changes.should be_nil
  end

  def do_callbacks(auditor, model)
    auditor.audit_before
    audit = auditor.instance_variable_get(:@audit)
    audit.saved.should be_false

    model.changes = nil
    model.id = 42 if model.id.nil?    

    auditor.audit_after
    auditor.instance_variable_get(:@audit)
  end

  def new_model(id = nil, changes = {})
    model = (Class.new do; attr_accessor :id, :changes; end).new
    model.id, model.changes = id, changes
    model
  end

  class Audit
    attr_accessor :audited_changes, :saved
    attr_accessor :action, :auditable_id, :auditable_type, :user_id, :user_type, :auditable_version, :comment

    def initialize(attrs={})
      @audited_changes = attrs.delete(:audited_changes)      
      @saved = false
      raise "You can only set the audited_changes field in this class" unless attrs.empty?
    end

    def attributes=(attrs={})
      attrs.each_pair do |key, val|
        self.send("#{key}=".to_sym, val)
      end
    end

    def save
      @saved = true
    end
  end
end
