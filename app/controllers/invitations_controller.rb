class InvitationsController < ApplicationController
  before_filter :require_logged_in_user,
    :except => [ :build, :create_by_request, :confirm_email ]

  def build
    @invitation_request = InvitationRequest.new
  end

  def index
    @invitation_requests = InvitationRequest.where(:is_verified => true)
  end

  def confirm_email
    if !(ir = InvitationRequest.where(:code => params[:code].to_s).first)
      flash[:error] = "Invalid or expired invitation request"
      return redirect_to "/invitations/request"
    end

    ir.is_verified = true
    ir.save!

    flash[:success] = "Your invitiation request has been validated and " <<
      "will now be shown to other logged-in users."
    return redirect_to "/invitations/request"
  end

  def create
    i = Invitation.new
    i.user_id = @user.id
    i.email = params[:email]
    i.memo = params[:memo]

    begin
      i.save!
      i.send_email
      flash[:success] = t("invitations.create.success", email: params[:email].to_s)
    rescue
      flash[:error] = t("invitations.create.error")
    end

    if params[:return_home]
      return redirect_to "/"
    else
      return redirect_to "/settings"
    end
  end

  def create_by_request
    @invitation_request = InvitationRequest.new(
      params.require(:invitation_request).permit(:name, :email, :memo))

    @invitation_request.ip_address = request.remote_ip

    if @invitation_request.save
      flash[:success] = "You have been e-mailed a confirmation to " <<
        params[:invitation_request][:email].to_s << "."
      return redirect_to "/invitations/request"
    else
      render :action => :build
    end
  end

  def send_for_request
    if !(ir = InvitationRequest.where(:code => params[:code].to_s).first)
      flash[:error] = "Invalid or expired invitation request"
      return redirect_to "/invitations"
    end

    i = Invitation.new
    i.user_id = @user.id
    i.email = ir.email

    i.save!
    i.send_email
    ir.destroy!
    flash[:success] = "Successfully e-mailed invitation to " <<
      ir.name.to_s << "."

    return redirect_to "/invitations"
  end

  def delete_request
    if !@user.is_moderator?
      return redirect_to "/invitations"
    end

    if !(ir = InvitationRequest.where(:code => params[:code].to_s).first)
      flash[:error] = "Invalid or expired invitation request"
      return redirect_to "/invitations"
    end

    ir.destroy!
    flash[:success] = "Successfully deleted invitation request from " <<
      ir.name.to_s << "."

    return redirect_to "/invitations"
  end
end
