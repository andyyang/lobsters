class EmailReply < ActionMailer::Base
  include ApplicationHelper
  
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def reply(comment, user)
    @comment = comment
    @user = user

    template_name = template_i18n_name('reply')

    mail(
      :to => user.email,
      :subject => t("email_reply.reply.subject", application: Rails.application.name, 
        user: comment.user.username, story: comment.story.title),
      template_name: template_name
    )
  end

  def mention(comment, user)
    @comment = comment
    @user = user

    template_name = template_i18n_name('mention')

    mail(
      :to => user.email,
      :subject => t("email_reply.mention.subject", application: Rails.application.name, 
        user: comment.user.username, story: comment.story.title),
      template_name: template_name
    )
  end
end
