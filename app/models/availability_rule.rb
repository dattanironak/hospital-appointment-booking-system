class AvailabilityRule < ApplicationRecord
  belongs_to :doctor, class_name: "User", inverse_of: :availability_rules

  WEEKDAYS = (0..6).freeze

  validates :weekday, presence: true, inclusion: { in: WEEKDAYS }
  validates :start_time, :end_time, presence: true
  validates :slot_duration_minutes, numericality: { only_integer: true, greater_than: 0 }
  validate :end_time_after_start_time
  validate :doctor_must_be_a_doctor

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def doctor_must_be_a_doctor
    errors.add(:doctor, "must have the doctor role") if doctor && !doctor.doctor?
  end
end
