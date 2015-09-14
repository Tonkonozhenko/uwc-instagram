require 'benchmark'

module InstaCollage
  class Montage
    POOL_SIZE = 25

    attr_reader :options

    def initialize(images, options = {})
      @images = prepare_urls(images)
      @options = options
    end

    def generate_collage
      montage = self

      download_images.each do |img|
        image = Magick::Image.read(img).first
        image.resize_to_fit!(150)
        image.write(img)
      end

      list = Magick::ImageList.new(*download_images)
      collage = list.montage do |m|
        m.geometry = '150x150'
        m.tile = montage.options[:tile] if montage.options[:tile]
      end

      file_name = "/images/collage#{Time.now.to_f}.png"
      collage.write "web/assets#{file_name}"
      file_name
    end

    def download_images
      ImageLoader.download_images(@images)
    end

    private
    def prepare_urls(images)
      images.map do |i|
        size = :standard_resolution
        i.images[size].url
      end
    end
  end
end