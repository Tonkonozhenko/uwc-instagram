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
    enable :sessions

    set :root, File.expand_path(File.dirname(__FILE__) + '/../../web')
    set :public_folder, -> { "#{root}/assets" }
    set :views, proc { "#{root}/views" }
    set :protect_from_csrf, false
    set :lock, false

    configure :production do
      use Rack::Auth::Basic, 'Password' do |username, password|
        username == 'uwc' && password == 'some_very_difficult_password'
      end
    end

    configure :development do
      register Sinatra::Reloader
      register Sinatra::QuietAssets

      also_reload 'lib/insta_collage/**/*.rb'

      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../..', __FILE__)
    end

    get '/' do
      @_env = self.class.environment
      slim :index, layout: :application
    end

    get '/login' do
      redirect Instagram.authorize_url(redirect_uri: ENV['CALLBACK_URL'])
    end

    get '/oauth/callback' do
      response = Instagram.get_access_token(params[:code], redirect_uri: ENV['CALLBACK_URL'])
      session[:access_token] = response.access_token
      redirect '/collage'
    end
  end
end