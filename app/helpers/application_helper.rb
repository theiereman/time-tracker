module ApplicationHelper
  def format_hour(hour)
    l(Time.zone.local(2000, 1, 1, hour), format: :hour)
  end

  def format_time(time)
    l(time, format: :time_of_day)
  end

  def contrasted_text_color(hex_color)
    r, g, b = hex_color.delete("#").scan(/../).map { |c| c.to_i(16) }
    luminance = (0.299 * r) + (0.587 * g) + (0.114 * b)
    luminance > 128 ? "var(--color-text)" : "var(--color-background)"
  end

  def darken_color(hex_color, amount = 0.2)
    r, g, b = hex_color.delete("#").scan(/../).map { |c| c.to_i(16) }
    "#%02x%02x%02x" % [ (r * (1 - amount)).round, (g * (1 - amount)).round, (b * (1 - amount)).round ]
  end
end
