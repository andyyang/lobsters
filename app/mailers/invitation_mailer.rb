class InvitationMailer < ActionMailer::Base
  include ApplicationHelper

  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def invitation(invitation)
    @invitation = invitation

    template_name = template_i18n_name('invitation')

    mail(
      :to => invitation.email,
      subject: t("invitation_mailer.invitation.subject", application: Rails.application.name),
      template_name: template_name
    )
  end
end
