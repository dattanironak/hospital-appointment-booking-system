class SessionsController < ApplicationController
  layout "auth"

  def new
    redirect_to_dashboard and return if logged_in?
  end

  def create
    user = User.active.find_by(email: params[:email].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to_dashboard
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "Signed out."
  end

  private

  def redirect_to_dashboard
    if current_user.admin?
      redirect_to admin_root_path
    else
      redirect_to doctor_root_path
    end
  end
end
