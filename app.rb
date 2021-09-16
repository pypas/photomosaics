# frozen_string_literal: true

require 'mini_magick'

SQUARE_SIZE = 20
PATH_IN = 'img/in.jpg'
PATH_OUT = 'img/out.jpg'

def get_average_color(pixels_cut)
  sum_pixels_line = pixels_cut.map { |a| a.transpose.map(&:sum) }.transpose
  sum_pixels_line.map { |b| (b.sum.to_f / (pixels_cut.length * pixels_cut[0].length)).to_i }
end

@src_average_colors = []
(0...100).each do |i|
  image = MiniMagick::Image.open("img/source_square/img_#{i}.jpg")
  pixels = image.get_pixels
  @src_average_colors.push(get_average_color(pixels))
end

def euclidean_distance(color1, color2)
  sum = 0
  color1.zip(color2).each do |v1, v2|
    component = (v1 - v2)**2
    sum += component
  end
  Math.sqrt(sum)
end

def closest_src_idx(color)
  differences = []
  (0...100).each do |i|
    src_color = @src_average_colors[i]
    euclidean = euclidean_distance(src_color, color)
    differences.push(euclidean)
  end
  differences.each_with_index.min[1]
end

def get_closest_image(pixels_cut)
  average_color = get_average_color(pixels_cut)
  idx = closest_src_idx(average_color)
  img = MiniMagick::Image.open("img/source_square/img_#{idx}.jpg")
  min_side = [pixels_cut[0].length, pixels_cut.length].max
  img.resize("#{min_side}x#{min_side}")
  img.crop("#{pixels_cut[0].length}x#{pixels_cut.length}+0+0")
  img.get_pixels
end

def update_pixels(pixels, start_line, start_col)
  pixels_cut = pixels[start_line...start_line + SQUARE_SIZE].map { |a| a[start_col...start_col + SQUARE_SIZE] }

  px = get_closest_image(pixels_cut)

  (0...pixels_cut.length).each do |x|
    (0...pixels_cut[0].length).each do |y|
      pixels[x + start_line][y + start_col] = px[x][y]
    end
  end
  pixels
end

def photomosaics(pixels)
  (0...(pixels.length.to_f / SQUARE_SIZE).ceil).each do |i|
    (0...(pixels[0].length.to_f / SQUARE_SIZE).ceil).each do |j|
      pixels = update_pixels(pixels, i * SQUARE_SIZE, j * SQUARE_SIZE)
    end
  end
  pixels
end

image = MiniMagick::Image.open(PATH_IN)
pixels = photomosaics(image.get_pixels)
new_image = MiniMagick::Image.get_image_from_pixels(pixels, [pixels[0].length, pixels.length], 'rgb', 8, 'jpg')
new_image.write(PATH_OUT)
