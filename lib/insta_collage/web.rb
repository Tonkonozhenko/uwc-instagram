require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require 'padrino-helpers'

require 'slim'
require 'better_errors'

require_relative '../insta_collage/quiet_assets'
require_relative '../insta_collage'

module InstaCollage
  class Web < Sinatra::Base
    register Padrino::Helpers

    set :root, File.expand_path(File.dirname(__FILE__) + '/../../web')
    set :public_folder, -> { "#{root}/assets" }
    set :views, proc { "#{root}/views" }
    set :protect_from_csrf, false
    set :lock, false

    configure :development do
      register Sinatra::Reloader
      register Sinatra::QuietAssets

      also_reload 'lib/insta_collage/**/*.rb'

      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../..', __FILE__)
    end

    get '/' do
      json 'test'
    end
  end
end