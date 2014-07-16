class SignupController < ApplicationController
  before_filter :require_logged_in_user, :only => :invite

  def index
    if @user
      flash[:error] = t("signup.index.signed_up")
      return redirect_to "/"
    end

    @title = t("signup.index.title")
  end

  def invited
    if @user
      flash[:error] = t("signup.invited.signed_up")
      return redirect_to "/"
    end

    if !(@invitation = Invitation.where(:code => params[:invitation_code].to_s).first)
      flash[:error] = t("signup.invited.invalid_invitation")
      return redirect_to "/signup"
    end

    @title = t("signup.invited.title")

    @new_user = User.new
    @new_user.email = @invitation.email

    render :action => "invited"
  end

  def signup
    if !(@invitation = Invitation.where(:code => params[:invitation_code].to_s).first)
      flash[:error] = t("signup.signup.invalid_invitation")
      return redirect_to "/signup"
    end

    @title = t("signup.signup.title")

    @new_user = User.new(user_params)
    @new_user.invited_by_user_id = @invitation.user_id

    if @new_user.save
      @invitation.destroy
      session[:u] = @new_user.session_token
      flash[:success] = t("signup.signup.title", application: Rails.application.name, user: @new_user.username) 

      Countinual.count!("#{Rails.application.shortname}.users.created", "+1")

      return redirect_to "/signup/invite"
    else
      render :action => "invited"
    end
  end

private

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation, :about,
    )
  end
end
