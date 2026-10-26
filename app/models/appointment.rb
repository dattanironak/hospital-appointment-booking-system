class Appointment < ApplicationRecord
  belongs_to :doctor, class_name: "User", inverse_of: :appointments

  enum :status, { confirmed: 0, cancelled: 1 }

  before_create :generate_confirmation_token

  validates :patient_name, :patient_phone, presence: true
  validates :appointment_date, :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_confirmed_appointment, on: :create

  scope :upcoming, -> { where("appointment_date >= ?", Date.current).order(:appointment_date, :start_time) }

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(12)
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_confirmed_appointment
    return if doctor_id.blank? || appointment_date.blank? || start_time.blank?

    overlapping = doctor.appointments.confirmed
                         .where(appointment_date: appointment_date, start_time: start_time)
                         .exists?

    errors.add(:base, "slot is already booked") if overlapping
  end
end
