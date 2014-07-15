class InvitationMailer < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def invitation(invitation)
    @invitation = invitation

    if I18n.locale.to_s == "zh-CN"
      template_name = 'invitation_zh-cn'
    else
      template_name = 'invitation'
    end

    mail(
      :to => invitation.email,
      subject: t("invitation_mailer.invitation.subject", application: Rails.application.name),
      template_name: template_name
    )
  end
end
