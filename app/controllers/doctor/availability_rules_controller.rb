module Doctor
  class AvailabilityRulesController < BaseController
    def create
      rule = current_user.availability_rules.new(availability_rule_params)
      if rule.save
        redirect_to doctor_root_path, notice: "Weekly hours added."
      else
        redirect_to doctor_root_path, alert: rule.errors.full_messages.to_sentence
      end
    end

    def destroy
      # Scoped to the current doctor so no one can delete another doctor's rule.
      current_user.availability_rules.find(params[:id]).destroy
      redirect_to doctor_root_path, notice: "Weekly hours removed."
    end

    private

    def availability_rule_params
      params.permit(:weekday, :start_time, :end_time, :slot_duration_minutes)
    end
  end
end
