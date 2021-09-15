# frozen_string_literal: true

require 'mini_magick'

SQUARE_SIZE = 10
PATH_IN = 'img/src.jpg'
PATH_OUT = 'img/out.jpg'

image = MiniMagick::Image.open(PATH_IN)
pixels = image.get_pixels

def get_mean_pixels(pixels_cut)
  sum_pixels_line = pixels_cut.map { |a| a.transpose.map(&:sum) }.transpose
  sum_pixels_line.map { |b| (b.sum.to_f / (pixels_cut.length * pixels_cut[0].length)).to_i }
end

def update_pixels(pixels, start_line, start_col)
  pixels_cut = pixels[start_line...start_line + SQUARE_SIZE].map { |a| a[start_col...start_col + SQUARE_SIZE] }

  mean = get_mean_pixels(pixels_cut)
  (start_line...start_line + pixels_cut.length).each do |x|
    (start_col...start_col + pixels_cut[0].length).each do |y|
      pixels[x][y] = mean
    end
  end
  pixels
end

(0...(image.height.to_f / SQUARE_SIZE).ceil).each do |i|
  (0...(image.width.to_f / SQUARE_SIZE).ceil).each do |j|
    pixels = update_pixels(pixels, i * SQUARE_SIZE, j * SQUARE_SIZE)
  end
end

new_image = MiniMagick::Image.get_image_from_pixels(pixels, [pixels[0].length, pixels.length], 'rgb', 8, 'jpg')
new_image.write(PATH_OUT)
