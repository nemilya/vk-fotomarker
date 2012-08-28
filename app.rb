require 'rubygems'
require 'haml'
require 'sinatra'
require 'json'

require 'omniauth-vkontakte'
require 'vk-ruby'

# remote access to VK.api - work within IFrame
# VK_JS = true
# or local for direct URL test
VK_JS = false

enable :sessions
require 'init_vk'

before do
  headers 'X-Frame-Options'=> 'GOFORIT'
  @ts = ''
  configure :development do
    t = Time.now.strftime('%Y%m%d%H%M%S')
    @ts = "?#{t}"
  end

  if session[:token]
    @app = VK::Serverside.new :app_id=>ENV['API_KEY'], :app_secret=>ENV['API_SECRET'], :access_token=>session[:token]
  end
end

get '/' do
  haml :index
end

# some cache issues
get '/:name.haml' do
  file_path = "public/templates/#{params[:name]}.haml"
  File.open(file_path).read if File.exists?(file_path)
end


get '/auth/:name/callback' do
  auth_hash = request.env['omniauth.auth']
  session[:token] = auth_hash[:credentials][:token]
  session[:name] = auth_hash[:info][:name]
  redirect '/'
end

get '/logout' do
  session[:token] = nil
  session[:name] = nil
  redirect '/'
end



get '/albums.json' do
  albums = []
  if @app
    @app.photos.getAlbums(:count=>7).each do |a|
      albums << {:title=>a['title'], :aid=>a['aid']}
    end
  end
  albums.to_json
end

post '/upload_by_server' do
  require 'base64'
  require 'rest-client'

  upload_server = @app.photos.getUploadServer( :aid => '157753816' )
  upload_url = upload_server["upload_url"]

  # data:image/jpeg;base64,
  # data:image/png;base64,
  img = params[:image]
  img.gsub!(/data:image\/png;base64,/, '')

  cnt = Base64.decode64(img)
  response = nil

  # TODO uid file, remove
  File.open('res.png', 'wb') do |f|
    f << cnt
  end

  response = RestClient.post upload_url, :photo => File.new('res.png', 'rb')

#  require 'crack'
# Crack::
  upload_result = JSON.parse(response)

  info = {}
  info['aid']    = upload_result['aid']
  info['hash']   = upload_result['hash']
  info['server'] = upload_result['server']
  info['photos_list'] = upload_result['photos_list']
  res2 = @app.photos.save(upload_result)


  p res2
  res2.to_json
end