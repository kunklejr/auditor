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

  def verify_audit(audit, audited, user, action, audited_changes_nil=false, comment_nil=true)
    audit.auditable_id.should == audited.id
    audit.auditable_type.should == audited.class.name
    audit.user_id.should == user.id
    audit.user_type.should == user.class.name
    audit.action.should == action.to_s
    audit.comment.should be_nil if comment_nil
    audit.comment.should_not be_nil unless comment_nil
    audit.audited_changes.should be_nil if audited_changes_nil
    audit.audited_changes.should_not be_nil unless audited_changes_nil
  end
  
end


