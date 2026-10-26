module Admin
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_admin_role

    private

    def require_admin_role
      redirect_to new_session_path, alert: "Not authorized." unless current_user.admin?
    end
  end
end
