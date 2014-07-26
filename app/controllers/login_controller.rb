class LoginController < ApplicationController
  before_filter :authenticate_user

  def logout
    if @user
      reset_session
    end

    redirect_to "/"
  end

  def index
    @title = t("login.index.title")
    render :action => "index"
  end

  def login
    if params[:email].to_s.match(/@/)
      user = User.where(:email => params[:email]).first
    else
      user = User.where(:username => params[:email]).first
    end

    if user && user.is_active? &&
    user.try(:authenticate, params[:password].to_s)
      session[:u] = user.session_token
      return redirect_to "/"
    end

    flash.now[:error] = t("login.login.error")
    index
  end

  def forgot_password
    @title = t("login.forgot_password.title")
    render :action => "forgot_password"
  end

  def reset_password
    @found_user = User.where("email = ? OR username = ?", params[:email].to_s,
      params[:email].to_s).first

    if !@found_user
      flash.now[:error] = t("login.reset_password.error")
      return forgot_password
    end

    @found_user.initiate_password_reset_for_ip(request.remote_ip)

    flash.now[:success] = t("login.reset_password.success")
    return index
  end

  def set_new_password
    @title = t("login.set_new_password.title")

    if params[:token].blank? ||
    !(@reset_user = User.where(:password_reset_token => params[:token].to_s).first)
      flash[:error] = t("login.set_new_password.error")
      return redirect_to forgot_password_url
    end

    if params[:password].present?
      @reset_user.password = params[:password]
      @reset_user.password_confirmation = params[:password_confirmation]
      @reset_user.password_reset_token = nil

      # this will get reset upon save
      @reset_user.session_token = nil

      if @reset_user.save && @reset_user.is_active?
        session[:u] = @reset_user.session_token
        return redirect_to "/"
      end
    end
  end
end
