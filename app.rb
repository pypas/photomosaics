# frozen_string_literal: true

require 'mini_magick'
require 'json'

SQUARE_SIZE = 10
PATH_IN = 'img/in.jpg'
PATH_OUT = 'img/out.jpg'
PATH_SRC_IMAGES = 'img/source_square'
CACHE_PATH = 'average_colors_cache.json'

def get_average_color(pixels)
  line_sum = pixels.map { |a| a.transpose.map(&:sum) }.transpose
  line_sum.map { |b| (b.sum.to_f / (pixels.length * pixels[0].length)).to_i }
end

def get_euclidean_distance(color1, color2)
  sum = 0
  color1.zip(color2).each do |v1, v2|
    component = (v1 - v2)**2
    sum += component
  end
  Math.sqrt(sum)
end

def get_from_cache(image_name)
  unless @src_average_colors.key?(image_name)
    image = MiniMagick::Image.open("#{PATH_SRC_IMAGES}/#{image_name}")
    @src_average_colors[image_name] = get_average_color(image.get_pixels)
    File.write(CACHE_PATH, JSON.dump(@src_average_colors))
  end
  @src_average_colors[image_name]
end

def get_closest_image_idx(color)
  differences = []
  (0...100).each do |i|
    average_color = get_from_cache("img_#{i}.jpg")
    euclidean = get_euclidean_distance(average_color, color)
    differences.push(euclidean)
  end
  differences.each_with_index.min[1]
end

def get_closest_image(pixels)
  average_color = get_average_color(pixels)
  idx = get_closest_image_idx(average_color)
  img = MiniMagick::Image.open("#{PATH_SRC_IMAGES}/img_#{idx}.jpg")

  long_side = [pixels[0].length, pixels.length].max
  img.resize("#{long_side}x#{long_side}")
  img.crop("#{pixels[0].length}x#{pixels.length}+0+0")

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

cache_file = File.read(CACHE_PATH)
@src_average_colors = JSON.parse(File.read(CACHE_PATH))

image = MiniMagick::Image.open(PATH_IN)
pixels = photomosaics(image.get_pixels)
new_image = MiniMagick::Image.get_image_from_pixels(pixels, [pixels[0].length, pixels.length], 'rgb', 8, 'jpg')
new_image.write(PATH_OUT)
