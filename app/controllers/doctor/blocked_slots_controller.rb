module Doctor
  class BlockedSlotsController < BaseController
    def create
      slot = current_user.blocked_slots.new(blocked_slot_params)
      if slot.save
        redirect_to doctor_root_path, notice: "Date blocked."
      else
        redirect_to doctor_root_path, alert: slot.errors.full_messages.to_sentence
      end
    end

    def destroy
      # Scoped to the current doctor so no one can remove another doctor's block.
      current_user.blocked_slots.find(params[:id]).destroy
      redirect_to doctor_root_path, notice: "Block removed."
    end

    private

    def blocked_slot_params
      params.permit(:date, :start_time, :end_time)
    end
  end
end
