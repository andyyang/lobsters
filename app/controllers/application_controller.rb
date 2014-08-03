class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user
  before_filter :increase_traffic_counter

  TRAFFIC_DECREMENTER = 0.25

  TAG_FILTER_COOKIE = :tag_filters

  def authenticate_user
    if session[:u] &&
    (user = User.where(:session_token => session[:u].to_s).first) &&
    user.is_active?
      @user = user
      Rails.logger.info "  Logged in as user #{@user.id} (#{@user.username})"
    end

    true
  end

  def increase_traffic_counter
    @traffic = 1.0

    if user_is_spider? || [ "json", "rss" ].include?(params[:format])
      return true
    end

    Keystore.transaction do
      now_i = Time.now.to_i
      date_kv = Keystore.find_or_create_key_for_update("traffic:date", now_i)
      traffic_kv = Keystore.find_or_create_key_for_update("traffic:hits", 0)

      # increment traffic counter on each request
      traffic = traffic_kv.value.to_i + 100
      # every second, decrement traffic by some amount
      traffic -= (100.0 * (now_i - date_kv.value) * TRAFFIC_DECREMENTER).to_i
      # clamp
      traffic = [ 100, traffic ].max

      @traffic = traffic * 0.01

      traffic_kv.value = traffic
      traffic_kv.save!

      date_kv.value = now_i
      date_kv.save!
    end

    Rails.logger.info "  Traffic level: #{@traffic}"

    true
  end

  def require_logged_in_user
    if @user
      true
    else
      redirect_to "/login"
    end
  end

  def require_logged_in_user_or_400
    if @user
      true
    else
      render :text => t("application.require_logged_in_user_or_400.no_login"), :status => 400
      return false
    end
  end

  @_tags_filtered = nil
  def tags_filtered_by_cookie
    @_tags_filtered ||= Tag.where(
      :tag => cookies[TAG_FILTER_COOKIE].to_s.split(",")
    )
  end

  def user_is_spider?
    !!request.env["HTTP_USER_AGENT"].to_s.match(/Googlebot/)
  end

  def find_user_from_rss_token
    if !@user && request[:format] == "rss" && params[:token].to_s.present?
      @user = User.where(:rss_token => params[:token].to_s).first
    end
  end
end
