require 'instagram'
require 'dotenv'
require 'rmagick'
require 'celluloid/current'
require 'net/http'

Dotenv.load

require_relative 'insta_collage/initialize'
require_relative 'insta_collage/image_loader'
require_relative 'insta_collage/montage'

module InstaCollage

end