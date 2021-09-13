# frozen_string_literal: true

require 'mini_magick'

image = MiniMagick::Image.open('img/src.jpg')
image.contrast
image.write('img/out.jpg')
