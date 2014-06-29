module ApplicationHelper
  def errors_for(object, message=nil)
    html = ""
    unless object.errors.blank?
      html << "<div class=\"flash-error\">\n"
      object.errors.full_messages.each do |error|
        html << error << "<br>"
      end
      html << "</div>\n"
    end

    raw(html)
  end

  def time_ago_in_words_label(*args)
    label_tag(nil, time_ago_in_words(*args),
      :title => args.first.strftime("%F %T %z"))
  end

  def user_type(user)
    if user.is_admin?
        t("messages.show.administrator")
    elsif user.is_moderator?
        t("messages.show.moderator")
    end
  end
end
