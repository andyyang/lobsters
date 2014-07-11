class InvitationRequestMailer < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def invitation_request(invitation_request)
    @invitation_request = invitation_request

    mail(
      :to => invitation_request.email,
      subject: t("invitation_request_mailer.invitation_request.subject", application: Rails.application.name)
    )
  end
end
