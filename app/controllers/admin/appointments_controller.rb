module Admin
  class AppointmentsController < BaseController
    def index
      @doctors = User.doctor.order(:name)
      scope = Appointment.confirmed.upcoming.includes(:doctor)
      scope = scope.where(doctor_id: params[:doctor_id]) if params[:doctor_id].present?
      @appointments = scope
    end
  end
end
