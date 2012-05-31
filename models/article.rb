class Article < Sequel::Model
  many_to_one :event
  many_to_one :photo_preview
  many_to_one :user

  def author
    return "washulol" unless self.user
    self.user.username || self.user.email
  end

  def relative_created_at
    diff = (Time.now - self.created_at).to_i
    case diff
      when 0 then return "just now"
      when 1 then return "1 second ago"
      when 2..59 then return "#{diff.to_s} seconds ago"
      when 60..89 then return "1 minute ago"
      when 90..3569 then return "#{(diff / 60.0).round.to_s} minutes ago"
      when 3570..5399 then return "1 hour ago"
      when 5400..84599 then return "#{(diff / (60.0 * 60)).round.to_s} hours ago"
      when 84600..129599 then return "1 day ago"
      else "on #{self.created_at.strftime("%b %-d, %Y")}"
    end
  end
end