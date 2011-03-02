require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/user'
require 'auditor/status'

describe Auditor::Auditable do
  include Auditor::Status

  before(:each) do
    @user = User.create
    Auditor::User.current_user = @user
  end

  it 'should audit find' do
    redefine_model { audit!(:find) }
    m = without_auditing { Model.create }

    Model.find(m.id)

    verify_audit(Audit.last, m)
  end

  it 'should audit create' do
    redefine_model { audit!(:create) }

    m = Model.create(:name => 'new')

    verify_audit(Audit.last, m, { 'name' => [nil, 'new'], 'id' => [nil, m.id] })
  end

  it 'should audit update' do
    redefine_model { audit!(:update) }
    m = without_auditing { Model.create(:name => 'new') }

    m.update_attributes(:name => 'newer')

    verify_audit(Audit.last, m, { 'name' => ['new', 'newer'] })
  end

  it 'should audit destroy' do
    redefine_model { audit!(:destroy) }
    m = without_auditing { Model.create }

    m.destroy

    verify_audit(Audit.last, m)
  end

  it 'should allow multiple actions to be specified with one audit statment' do
    redefine_model { audit!(:create, :destroy) }

    m = Model.create
    m.reload
    m = Model.find(m.id)
    m.update_attributes({:name => 'new'})
    m.destroy

    Audit.count.should == 2
  end

  it 'should record the comment returned from a comment block' do
    redefine_model { audit!(:create) { 'comment' } }
    Model.create
    Audit.last.comment.should == 'comment'
  end

  it 'should provide the model object and user as parameters to the comment block' do
    id = without_auditing { Model.create }.id
    user = @user
    redefine_model {
      audit!(:find) { |model, user|
        model.id.should == id
        user.should == user
      }
    }
    Model.find(id)
  end

  it 'should provide a snapshot of the object attributes at a given date or time' do
    redefine_model { audit!(:create, :find, :update, :destroy) }
    m = Model.create(:name => '1')
    ts1 = Time.now
    m = Model.find(m.id)
    ts2 = Time.now
    m.update_attributes(:name => '2')
    ts3 = Time.now
    m.destroy
    ts4 = Time.now

    m.attributes_at(ts1).should == {'name' => '1', 'id' => m.id}
    m.attributes_at(ts2).should == {'name' => '1', 'id' => m.id}
    m.attributes_at(ts3).should == {'name' => '2', 'id' => m.id}
    m.attributes_at(ts4).should == {'name' => '2', 'id' => m.id}
  end

  def verify_audit(audit, model, changes=nil)
    audit.should_not be_nil
    audit.auditable.should == model unless audit.action == 'destroy'
    audit.user.should == @user
    audit.audited_changes.should == changes unless changes.nil?
  end

  def redefine_model(&blk)
    clazz = Class.new(ActiveRecord::Base, &blk)
    Object.send :remove_const, 'Model'
    Object.send :const_set, 'Model', clazz
  end

  class ::User < ActiveRecord::Base; end
  class ::Model < ActiveRecord::Base; end

end
