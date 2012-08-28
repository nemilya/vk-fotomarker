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
