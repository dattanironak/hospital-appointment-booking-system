module Doctor
  class DashboardController < BaseController
    def show
      @availability_rules = current_user.availability_rules.order(:weekday, :start_time)
      @blocked_slots = current_user.blocked_slots.where("date >= ?", Date.current).order(:date, :start_time)
      @appointments = current_user.appointments.confirmed.upcoming

      @appointments_by_date = @appointments.group_by(&:appointment_date)
      @rules_by_weekday = @availability_rules.group_by(&:weekday)
      @today_count = @appointments_by_date.fetch(Date.current, []).size
      @week_count = @appointments.count { |appt| appt.appointment_date < Date.current + 7 }
      @weekly_hours = (@availability_rules.sum { |rule| rule.end_time - rule.start_time } / 3600.0).round(1)
    end
  end
end
