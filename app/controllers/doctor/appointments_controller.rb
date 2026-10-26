module Doctor
  class AppointmentsController < BaseController
    # Scoped to the current doctor so no one can view, edit or cancel another doctor's appointment.
    before_action :set_appointment, only: [ :edit, :update, :destroy ]

    def new
      @appointment = current_user.appointments.new
      @date = parse_date(params[:date]) || Date.current
      @slots = slot_options(@date)
    end

    def create
      @appointment = current_user.appointments.new(appointment_params)
      slot = chosen_slot
      return render_slot_unavailable(:new) if slot.nil?

      @appointment.assign_attributes(appointment_date: @date, start_time: slot.start_time, end_time: slot.end_time)

      if @appointment.save
        SendWhatsappConfirmationJob.perform_later(@appointment.id)
        redirect_to doctor_calendar_path(date: @date.iso8601), notice: "Appointment booked."
      else
        @slots = slot_options(@date)
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @date = parse_date(params[:date]) || @appointment.appointment_date
      @slots = slot_options(@date)
    end

    def update
      slot = chosen_slot
      return render_slot_unavailable(:edit) if slot.nil?

      if @appointment.update(appointment_params.merge(appointment_date: @date, start_time: slot.start_time, end_time: slot.end_time))
        redirect_to doctor_calendar_path(date: @date.iso8601), notice: "Appointment updated."
      else
        @slots = slot_options(@date)
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @appointment.update!(status: :cancelled)
      redirect_back_or_to doctor_root_path, notice: "Appointment cancelled."
    end

    private

    def set_appointment
      @appointment = current_user.appointments.confirmed.find(params[:id])
    end

    def appointment_params
      params.require(:appointment).permit(:patient_name, :patient_phone)
    end

    # Sets @date from the submitted form and returns the matching bookable slot, or nil.
    def chosen_slot
      @date = parse_date(params.dig(:appointment, :appointment_date))
      @date && slot_options(@date).find { |s| s.start_time.strftime("%H:%M") == params.dig(:appointment, :start_time) }
    end

    def render_slot_unavailable(template)
      @appointment.assign_attributes(appointment_params)
      @date ||= @appointment.appointment_date || Date.current
      @slots = slot_options(@date)
      flash.now[:alert] = "That time is no longer available. Please pick another slot."
      render template, status: :unprocessable_content
    end

    # Open slots for the date, plus the appointment's own current slot (which
    # SlotCalculator reports as booked) so it can stay put while other details change.
    def slot_options(date)
      slots = SlotCalculator.call(doctor: current_user, date: date)

      if @appointment.persisted? && date == @appointment.appointment_date_in_database
        slots << SlotCalculator::Slot.new(@appointment.start_time_in_database, @appointment.end_time_in_database)
      end

      slots.uniq { |s| s.start_time.strftime("%H:%M") }.sort_by { |s| s.start_time.strftime("%H:%M") }
    end

    def current_slot?(slot)
      @appointment.persisted? &&
        @date == @appointment.appointment_date_in_database &&
        slot.start_time.strftime("%H:%M") == @appointment.start_time_in_database.strftime("%H:%M")
    end
    helper_method :current_slot?

    def parse_date(value)
      Date.iso8601(value.to_s) if value.present?
    rescue ArgumentError
      nil
    end
  end
end
