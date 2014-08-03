class EmailMessage < ActionMailer::Base
  include ApplicationHelper

  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def notify(message, user)
    @message = message
    @user = user

    template_name = template_i18n_name('notify')

    mail(
      :to => user.email,
      :subject => "[#{Rails.application.name}] Private Message from " <<
        "#{message.author.username}: #{message.subject}",
      template_name: template_name
    )
  end
end
