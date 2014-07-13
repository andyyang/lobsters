class InvitationRequestMailer < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def invitation_request(invitation_request)
    @invitation_request = invitation_request

    if I18n.locale.to_s == "zh-CN"
      template_name = 'invitation_request_zh-cn'
    else
      template_name = 'invitation_request'
    end

    mail(
      :to => invitation_request.email,
      subject: t("invitation_request_mailer.invitation_request.subject", application: Rails.application.name),
      template_name: template_name
    )
  end
end
