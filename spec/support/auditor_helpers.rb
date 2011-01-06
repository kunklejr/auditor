module AuditorHelpers
    
  def current_user=(user)
    Auditor::User.current_user = user
  end
  
  def current_user
    Auditor::User.current_user
  end
  
  def clear_current_user
    Auditor::User.current_user = nil
  end
  
  def verify_audit(audit, audited, user, action, edits_nil=false, message_nil=true)
    audit.auditable_id.should == audited.id
    audit.auditable_type.should == audited.class.name
    audit.user_id.should == user.id
    audit.user_type.should == user.class.name
    audit.action.should == action.to_s
    audit.message.should be_nil if message_nil
    audit.message.should_not be_nil unless message_nil
    audit.edits.should be_nil if edits_nil
    audit.edits.should_not be_nil unless edits_nil
  end
  
end


