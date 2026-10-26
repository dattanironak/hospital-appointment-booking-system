class BlockedSlot < ApplicationRecord
  belongs_to :doctor, class_name: "User", inverse_of: :blocked_slots

  validates :date, presence: true
  validate :end_time_after_start_time
  validate :both_or_neither_time_present

  # A nil start_time/end_time means the whole day is blocked.
  def whole_day?
    start_time.blank? && end_time.blank?
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def both_or_neither_time_present
    return if start_time.present? == end_time.present?

    errors.add(:base, "start_time and end_time must both be present or both be blank")
  end
end
