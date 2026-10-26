admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123")

admin = User.find_or_initialize_by(email: admin_email)
admin.assign_attributes(name: "Clinic Admin", role: :admin, active: true)
admin.password = admin_password if admin.new_record?
admin.save!

puts "Admin ready: #{admin.email} (set ADMIN_EMAIL/ADMIN_PASSWORD env vars to customize)"
