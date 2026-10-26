module Doctor
  class CalendarController < BaseController
    def show
      requested_date = parse_date(params[:date])
      @month = parse_month(params[:month]) || (requested_date || Date.current).beginning_of_month
      @selected_date = requested_date || (@month == Date.current.beginning_of_month ? Date.current : @month)

      # Full Monday-first weeks covering the month, so the grid is always rectangular.
      grid = @month.beginning_of_week(:monday)..@month.end_of_month.end_of_week(:monday)
      @days = grid.to_a

      @booked_counts = current_user.appointments.confirmed.where(appointment_date: grid).group(:appointment_date).count
      @working_weekdays = current_user.availability_rules.distinct.pluck(:weekday).to_set
      @blocked_dates = current_user.blocked_slots.where(date: grid).select(&:whole_day?).to_set(&:date)

      @day_appointments = current_user.appointments.confirmed.where(appointment_date: @selected_date).order(:start_time)
      @open_slots = SlotCalculator.call(doctor: current_user, date: @selected_date)
    end

    private

    def parse_date(value)
      Date.iso8601(value.to_s) if value.present?
    rescue ArgumentError
      nil
    end

    def parse_month(value)
      Date.strptime(value.to_s, "%Y-%m") if value.present?
    rescue ArgumentError
      nil
    end
  end
end
