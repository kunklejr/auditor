require File.dirname(__FILE__) + '/spec_helper'
require 'auditor/audit'

describe Audit do
  before(:each) do
    @auditable = Model.create
    @user = User.create
  end

  it 'should set the version number on save' do
    audit = Audit.create(:auditable => @auditable, :owner => @auditable, :audited_changes => { :name => [nil, 'new']}, :user => @user, :action => :create)
    audit.version.should == 1
  end

  it 'should provide access to the audited model object' do
    audit = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :create)
    audit.auditable.should == @auditable
  end
  it 'should provide access to the user associated with the audit' do
    audit = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :create)
    audit.user.should == @user
  end

  it 'should create a snapshot of the audited objects attributes at the time of the audit' do
    audit1 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :create)
    audit2 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'name' => [nil, 'n1'], 'value' => [nil, 'v1']})
    audit3 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :find)
    audit4 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'value' => [nil, 'v2']})

    audit1.attribute_snapshot.should == {}
    audit2.attribute_snapshot.should == {'name' => 'n1', 'value' => 'v1'}
    audit3.attribute_snapshot.should == {'name' => 'n1', 'value' => 'v1'}
    audit4.attribute_snapshot.should == {'name' => 'n1', 'value' => 'v2'}
  end

  describe 'modifying scope' do
    it 'should return all audit records that were a result of modifying the audited object attributes' do
      audit1 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :create, :audited_changes  => {'name' => [nil, 'n0']})
      audit2 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'name' => ['n0', 'n1'], 'value' => [nil, 'v1']})
      audit3 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :find)
      audit4 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'value' => [nil, 'v2']})

      Audit.modifying.should include(audit1, audit2, audit4)
      Audit.modifying.should_not include(audit3)
    end
  end

  describe 'predecessors scope' do
    it 'should return all previous audit records for the same auditable' do
      auditable2 = Model.create
      audit1 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :create)
      audit2 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'name' => [nil, 'n1'], 'value' => [nil, 'v1']})
      audit3 = Audit.create(:auditable => auditable2, :owner => auditable2, :user => @user, :action => :find)
      audit4 = Audit.create(:auditable => @auditable, :owner => @auditable, :user => @user, :action => :update, :audited_changes => {'value' => [nil, 'v2']})

      Audit.trail(audit4).should include(audit1, audit2, audit4)
      Audit.trail(audit4).should_not include(audit3)
    end
  end
end

