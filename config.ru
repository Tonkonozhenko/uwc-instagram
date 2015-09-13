require_relative 'lib/insta_collage/web'

run Rack::URLMap.new('/' => InstaCollage::Web)