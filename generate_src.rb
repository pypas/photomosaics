# frozen_string_literal: true

require 'mini_magick'

(0...100).each do |i|
  image = MiniMagick::Image.open("img/source/flower_00#{i.to_s.rjust(2, '0')}.jpg")
  small_size = [image.width, image.height].min
  image.crop("#{small_size}x#{small_size}+0+0")
  image.write("img/source_square/img_#{i}.jpg")
end
