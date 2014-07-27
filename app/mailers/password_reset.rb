class PasswordReset < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def password_reset_link(user, ip)
    @user = user
    @ip = ip

    if I18n.locale.to_s == "zh-CN"
      template_name = 'password_reset_link_zh-cn'
    else
      template_name = 'password_reset_link'
    end

    mail(
      :to => user.email,
      :subject => t("password_reset_mailer.password_reset_link.subject", application: Rails.application.name),
      template_name: template_name
    )
  end
end
