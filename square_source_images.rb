# frozen_string_literal: true

require 'mini_magick'

SRC_IMAGE_FOLDER = "img/source"
SRC_SQUARE_FOLDER = "img/source_square"

Dir.entries(SRC_IMAGE_FOLDER).each do |img_name|
  image = MiniMagick::Image.open("#{SRC_IMAGE_FOLDER}/#{img_name}")
  smaller_side = [image.width, image.height].min
  image.crop("#{smaller_side}x#{smaller_side}+0+0")
  image.write("#{SRC_SQUARE_FOLDER}/img_#{i}.jpg")
end
