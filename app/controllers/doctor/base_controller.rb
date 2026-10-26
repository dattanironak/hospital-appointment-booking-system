module Doctor
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_doctor_role

    private

    def require_doctor_role
      redirect_to new_session_path, alert: "Not authorized." unless current_user.doctor?
    end
  end
end
