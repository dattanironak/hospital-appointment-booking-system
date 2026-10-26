class SendWhatsappConfirmationJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return if appointment.nil?

    WhatsappNotifier.send_appointment_confirmation(appointment)
  rescue Twilio::REST::TwilioError, WhatsappNotifier::NotConfigured => e
    Rails.logger.error("WhatsApp confirmation failed for appointment #{appointment_id}: #{e.message}")
  end
end
