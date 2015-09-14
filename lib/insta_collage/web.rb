require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require 'padrino-helpers'

require 'slim'
require 'better_errors'

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

      also_reload 'lib/insta_collage/**/*.rb'

      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../..', __FILE__)
    end

    get '/' do
      redirect '/collage' if session[:access_token].present?
      slim :index, layout: :application
    end

    get '/login' do
      redirect Instagram.authorize_url(redirect_uri: ENV['CALLBACK_URL'])
    end

    get '/logout' do
      session[:access_token] = nil
      redirect '/'
    end

    get '/auth/callback' do
      response = Instagram.get_access_token(params[:code], redirect_uri: ENV['CALLBACK_URL'])
      session[:access_token] = response.access_token
      redirect '/collage'
    end

    get '/collage' do
      redirect '/' if session[:access_token].blank?

      @tag = params[:tag].presence
      @width = params[:width].present? ? params[:width].to_i : 5
      @height = params[:height].present? ? params[:height].to_i : 3
      @image = Montage.new(total_media, montage_options).generate_collage

      slim :collage, layout: :application
    end

    private
    def montage_options
      {
        tile: "#{@width}x#{@height}"
      }
    end

    def total_media
      client = Instagram.client(access_token: session[:access_token])

      total = @width * @height
      enough_images = total == 0
      images = []

      until enough_images
        images += if @tag.present?
                    client.tag_recent_media(@tag)[0...total - images.length]
                  else
                    client.media_popular[0...total - images.length]
                  end
        enough_images = total == images.length
      end

      images
    end
  end
end