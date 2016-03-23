class Picture < ActiveRecord::Base
  mount_uploader :filename, PictureUploader
end
