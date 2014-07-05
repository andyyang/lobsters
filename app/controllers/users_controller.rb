class UsersController < ApplicationController
  def show
    @showing_user = User.where(:username => params[:username]).first!
    @title = t("users.show.title", name: @showing_user.username)
  end

  def tree
    @title = t("users.tree.title")

    users = User.order("id DESC").to_a

    @user_count = users.length
    @users_by_parent = users.group_by(&:invited_by_user_id)
  end

  def invite
    @title = t("users.invite.title")
  end
end
