window.app = $.sammy ->
  @element_selector = '#content'
  @use(Sammy.Haml, 'haml')

app.img_url = ''

app.get '#/wait', ->
  @partial 'wait.haml'

app.get '#/', ->
  @app.swap('Hello!')
  @redirect '#/select_url'

app.get '#/select_url', ->
  @load('/albums.json').then (albums) ->
    @partial 'select_url.haml', albums: albums

app.get '#/sketch', ->
  if @params.url?
    @app.img_url = @params.url
  if @params.aid?
    @app._aid = @params.aid
  @partial 'sketch.haml', url: @app.img_url


app.get '#/upload_by_server', ->
  canvas = $('#tools_sketch')[0]
  image_base64 = canvas.toDataURL()
  $.post '/upload_by_server', 
    { image: image_base64 }
    (data) =>
      console.log 'upload by server'
      console.log data
      @redirect '#/sketch'

# chain:
#  1. get_upload_server
#  2. upload_to_server
#  3. upload_to_vk
# 

app.get '#/upload', ->
  @redirect '#/get_upload_server'
  
app.get '#/get_upload_server', ->
  console.log 'in get_upload_server'
  if VK?
    VK.api 'photos.getUploadServer', {aid: app._aid}, (data) =>
      console.log 'get_upload_server data:'
      console.log data
      if data.response
        app.upload_url = data.response.upload_url
        console.log app.upload_url
        @redirect '#/upload_to_server'

app.get '#/upload_to_server', ->
  canvas = $('#tools_sketch')[0]
  image_base64 = canvas.toDataURL()
  $.post '/upload', 
    { image: image_base64, url: app.upload_url }
    (data) =>
      app._json = $.parseJSON(data)
      console.log 'upload_to_server app._json:'
      console.log app._json
      @redirect '#/upload_to_vk'

app.get '#/upload_to_vk', ->
  # {"server":319930,"photos_list":"[]","aid":157753816,"hash":"3be3a8d4a74d43e4776e7975bf3a709c"}
  console.log 'upload_to_vk'
  info = app._json
  if VK?
    console.log 'in photos.save'
    console.log info
    # {aid: info.aid, server: info.server, photos_list: info.photos_list, hash: info.hash}
    VK.api 'photos.save', info, (data) =>
      console.log 'in Response photo save'
      console.log data
      @redirect '#/sketch'

$('#bgctrl')
  .live 'click', ->
    canvas = $('#tools_sketch')
    if $(this).is(':checked')
      canvas.css('background-image', 'none');
    else
      canvas.css('background-image', "url(#{app.img_url})");

  
if VK?
  VK.init ->
    app.run('#/')
else
  app.run('#/')
