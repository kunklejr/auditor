require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/user'

describe Auditor::Recorder do
  before(:each) do
    @user = Auditor::User.current_user = User.create
  end

  it 'should create an audit record for create actions' do
    verify_action(:create)
  end

  it 'should create an audit record for find actions' do
    verify_action(:find)
  end

  it 'should create an audit record for update actions' do
    verify_action(:update)
  end

  it 'should create an audit record for destroy actions' do
    verify_action(:destroy)
  end

  def verify_action(action)
    model = Model.create
    model.reload
    model.name = 'changed'
    config = Auditor::Config.new(action)

    recorder = Auditor::Recorder.new(config.options) { 'comment' }
    recorder.send "after_#{action}", model
    audit = Audit.last

    audit.action.should == action.to_s
    audit.auditable_id.should == model.id
    audit.auditable_type.should == model.class.to_s
    audit.user_id.should == @user.id
    audit.user_type.should == @user.class.to_s
    audit.comment.should == 'comment'
    audit.audited_changes.should == {'name' => [nil, 'changed'] } if [:create, :update].include?(action)

    audit.user.should == @user
    audit.auditable.should == model
  end

  it 'should set comment details to nil if they are not given' do
    model = Model.create
    config = Auditor::Config.new(:create)

    recorder = Auditor::Recorder.new(config.options)
    recorder.after_create(model)
    audit = Audit.last

    audit.comment.should be_nil
  end

  it 'should not save change details for excepted attributes' do
    model = Model.create
    model.name = 'changed'
    model.value = 'newval'
    config = Auditor::Config.new(:create, :except => :name)

    recorder = Auditor::Recorder.new(config.options)
    recorder.after_create(model)
    audit = Audit.last

    audit.audited_changes.should == {'value' => [nil, 'newval'] }
  end

  it 'should only save change details for onlyed attributes' do
    model = Model.create
    model.name = 'changed'
    model.value = 'newval'
    config = Auditor::Config.new(:create, :only => :name)

    recorder = Auditor::Recorder.new(config.options)
    recorder.after_create(model)
    audit = Audit.last

    audit.audited_changes.should == {'name' => [nil, 'changed'] }
  end

  class Model < ActiveRecord::Base; end
  class User < ActiveRecord::Base; end
end
