class Notifier < ActionMailer::Base

  def notification(notification)
    recipients notification.receiver.email
    from 'notifications@da.vin.ci'
    subject notification.notification_type.name
    body :text => notification.body
  end

  def invitation(invitation, options={})
    recipients invitation.receiver_email
    from invitation.sender.email
    subject 'Like Photography? Then you\'ll love da.vin.ci!'
    body :name => invitation.receiver_name, :code => invitation.code, :sender => invitation.sender.login
  end
end
