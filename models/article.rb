class Article < Sequel::Model
  many_to_one :event
  many_to_one :photo_preview
  many_to_one :user

  def author
    return "washulol" unless self.user
    return self.user.username || self.user.email
  end

  def type
    if self.event
      return "EVENT"
    elsif self.photo_preview
      return "PHOTOS"
    else
      "BLOG"
    end
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
      when 129600..1295999 then return "#{(diff / (60.0 * 60 * 24)).round.to_s} days ago"
      when 1296000..4060799 then return "1 month ago"
      when 4060800..15767999 then return "#{(diff / (60.0 * 60 * 24 * 30)).round.to_s} months ago"
      when 15768000..47433599 then return "1 year ago"
      else "#{(diff / (60.0 * 60 * 24 * 365)).round.to_s} years ago"
    end
  end
end