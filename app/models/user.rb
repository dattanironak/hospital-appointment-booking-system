class User < ApplicationRecord
  has_secure_password

  enum :role, { doctor: 0, admin: 1 }

  has_many :availability_rules, foreign_key: :doctor_id, inverse_of: :doctor, dependent: :destroy
  has_many :blocked_slots, foreign_key: :doctor_id, inverse_of: :doctor, dependent: :destroy
  has_many :appointments, foreign_key: :doctor_id, inverse_of: :doctor, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  before_save { self.email = email.downcase.strip if email.present? }

  scope :active, -> { where(active: true) }
end
