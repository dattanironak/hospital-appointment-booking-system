class SlotCalculator
  Slot = Struct.new(:start_time, :end_time) do
    def as_json(*)
      { start_time: start_time.strftime("%H:%M"), end_time: end_time.strftime("%H:%M") }
    end
  end

  def self.call(doctor:, date:)
    new(doctor, date).call
  end

  def initialize(doctor, date)
    @doctor = doctor
    @date = date
  end

  def call
    return [] if date < Date.current
    return [] if blocked_slots.any?(&:whole_day?)

    candidate_slots.reject { |slot| blocked?(slot) || already_booked?(slot) }
  end

  private

  attr_reader :doctor, :date

  def candidate_slots
    availability_rules.flat_map { |rule| slots_for_rule(rule) }.sort_by(&:start_time)
  end

  def slots_for_rule(rule)
    slots = []
    cursor = rule.start_time
    duration = rule.slot_duration_minutes.minutes

    while cursor + duration <= rule.end_time
      slots << Slot.new(cursor, cursor + duration)
      cursor += duration
    end

    slots
  end

  def availability_rules
    @availability_rules ||= doctor.availability_rules.where(weekday: date.wday)
  end

  def blocked_slots
    @blocked_slots ||= doctor.blocked_slots.where(date: date)
  end

  def blocked?(slot)
    blocked_slots.any? do |blocked|
      next false if blocked.whole_day?

      slot.start_time < blocked.end_time && slot.end_time > blocked.start_time
    end
  end

  def already_booked?(slot)
    booked_start_times.include?(slot.start_time.strftime("%H:%M:%S"))
  end

  def booked_start_times
    @booked_start_times ||= doctor.appointments.confirmed
                                   .where(appointment_date: date)
                                   .pluck(:start_time)
                                   .map { |t| t.strftime("%H:%M:%S") }
                                   .to_set
  end
end
