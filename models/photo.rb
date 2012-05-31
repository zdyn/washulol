class Photo < Sequel::Model
  many_to_one :articles

  def filename(thumbnail = false)
    prefix = thumbnail ? "tn-" : ""
    "#{prefix}photo-#{self.id}.jpg"
  end
end