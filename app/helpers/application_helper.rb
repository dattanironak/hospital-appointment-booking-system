module ApplicationHelper
  # Displayed in the header, sign-in page and <title>. Override per deployment.
  def clinic_name
    ENV.fetch("CLINIC_NAME", "MediBook")
  end

  # Monday-first ordering of Date::DAYNAMES indexes (0 = Sunday).
  WEEK_ORDER = [ 1, 2, 3, 4, 5, 6, 0 ].freeze

  def initials(name)
    name.to_s.sub(/\Adr\.?\s+/i, "").split.first(2).map { |part| part[0] }.join.upcase
  end

  def doctor_name(user)
    user.name.match?(/\Adr\.?\s/i) ? user.name : "Dr. #{user.name}"
  end

  def greeting
    case Time.current.hour
    when 0...12 then "Good morning"
    when 12...17 then "Good afternoon"
    else "Good evening"
    end
  end

  def day_heading(date)
    return "Today" if date == Date.current
    return "Tomorrow" if date == Date.current + 1

    date.strftime("%A, %b %-d")
  end

  def clock(time)
    time.strftime("%-I:%M %p")
  end

  def nav_link(label, path)
    link_to label, path, class: [ "nav-link", ("is-active" if current_page?(path)) ]
  end

  ICONS = {
    logo: '<path d="M9 3h6v6h6v6h-6v6H9v-6H3V9h6z"/>',
    calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    users: '<circle cx="9" cy="8" r="4"/><path d="M2 21a7 7 0 0 1 14 0M17 4a4 4 0 0 1 0 8M22 21a7 7 0 0 0-4-6.3"/>',
    phone: '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2"/>',
    ban: '<circle cx="12" cy="12" r="9"/><path d="M5.7 5.7l12.6 12.6"/>',
    logout: '<path d="M9 4H5a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h4M16 17l5-5-5-5M21 12H9"/>',
    plus: '<path d="M12 5v14M5 12h14"/>',
    x: '<path d="M6 6l12 12M18 6L6 18"/>',
    mail: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>',
    lock: '<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
    check: '<path d="M5 12l5 5L20 7"/>',
    shield: '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/>'
  }.freeze

  def icon(name, size: 18, css: nil)
    fill = name == :logo ? "currentColor" : "none"
    tag.svg(ICONS.fetch(name).html_safe, class: [ "icon", css ], width: size, height: size,
            viewBox: "0 0 24 24", fill: fill, stroke: (fill == "none" ? "currentColor" : nil),
            "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", "aria-hidden": true)
  end
end
