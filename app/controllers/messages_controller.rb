class MessagesController < ApplicationController
  before_filter :require_logged_in_user
  before_filter :find_message, :only => [ :show, :destroy, :keep_as_new ]

  def index
    @cur_url = "/messages"
    @title = t("messages.index.title")

    @new_message = Message.new

    @direction = :in
    @messages = @user.undeleted_received_messages

    if params[:to]
      @new_message.recipient_username = params[:to]
    end
  end

  def sent
    @cur_url = "/messages"
    @title = t("messages.sent.title")

    @direction = :out
    @messages = @user.undeleted_sent_messages

    @new_message = Message.new

    render :action => "index"
  end

  def create
    @cur_url = "/messages"
    @title = t("messages.create.title")

    @new_message = Message.new(message_params)
    @new_message.author_user_id = @user.id

    @direction = :out
    @messages = @user.undeleted_received_messages

    if @new_message.save
      flash[:success] = t("messages.create.success", user: @new_message.recipient.username.to_s)
      return redirect_to "/messages"
    else
      render :action => "index"
    end
  end

  def show
    @cur_url = "/messages"
    @title = @message.subject

    @new_message = Message.new
    @new_message.recipient_username = (@message.author_user_id == @user.id ?
      @message.recipient.username : @message.author.username)

    if @message.recipient_user_id == @user.id
      @message.has_been_read = true
      @message.save
    end

    if @message.subject.match(/^re:/i)
      @new_message.subject = @message.subject
    else
      @new_message.subject = "Re: #{@message.subject}"
    end
  end

  def destroy
    if @message.author_user_id == @user.id
      @message.deleted_by_author = true
    end

    if @message.recipient_user_id == @user.id
      @message.deleted_by_recipient = true
    end

    @message.save!

    flash[:success] = t("messages.destroy.success")

    if @message.author_user_id == @user.id
      return redirect_to "/messages/sent"
    else
      return redirect_to "/messages"
    end
  end

  def batch_delete
    deleted = 0

    params.each do |k,v|
      if v.to_s == "1" && m = k.match(/^delete_(.+)$/)
        if (message = Message.where(:short_id => m[1]).first)
          if message.author_user_id == @user.id
            message.deleted_by_author = true
          elsif message.recipient_user_id == @user.id
            message.deleted_by_recipient = true
          else
            next
          end

          message.save!
          deleted += 1
        end
      end
    end

    flash[:success] = t("messages.batch_delete.success", count: deleted, message: t("messages.batch_delete.message")) 

    return redirect_to "/messages"
  end

  def keep_as_new
    @message.has_been_read = false
    @message.save

    return redirect_to "/messages"
  end

private

  def message_params
    params.require(:message).permit(
      :recipient_username, :subject, :body,
    )
  end

  def find_message
    if @message = Message.where(:short_id => params[:message_id] || params[:id]).first
      if (@message.author_user_id == @user.id ||
      @message.recipient_user_id == @user.id)
        return true
      end
    end

    flash[:error] = t("messages.find_message.error")
    redirect_to "/messages"
    return false
  end
end
