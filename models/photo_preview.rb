class PhotoPreview < Sequel::Model
  one_to_one :article
end