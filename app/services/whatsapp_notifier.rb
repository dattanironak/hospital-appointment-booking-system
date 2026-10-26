class WhatsappNotifier
  class NotConfigured < StandardError; end

  REQUIRED_ENV = %w[TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_WHATSAPP_FROM].freeze

  def self.client
    Twilio::REST::Client.new(ENV.fetch("TWILIO_ACCOUNT_SID"), ENV.fetch("TWILIO_AUTH_TOKEN"))
  end

  def self.send_appointment_confirmation(appointment)
    missing = REQUIRED_ENV.select { |key| ENV[key].blank? }
    raise NotConfigured, "Twilio is not configured (missing #{missing.join(', ')})" if missing.any?

    doctor = appointment.doctor
    body = <<~MSG.strip
      Your appointment with Dr. #{doctor.name} is confirmed for #{appointment.appointment_date.strftime('%A, %b %-d')} at #{appointment.start_time.strftime('%I:%M %p')}.
    MSG

    client.messages.create(
      from: "whatsapp:#{ENV.fetch('TWILIO_WHATSAPP_FROM')}",
      to: "whatsapp:#{appointment.patient_phone}",
      body: body
    )
  end
end
