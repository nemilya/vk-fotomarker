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
  @partial 'select_url.haml'

app.get '#/sketch', ->
  if @params.url?
    @app.img_url = @params.url
  @partial 'sketch.haml', url: @app.img_url


$('#bgctrl')
  .live 'click', ->
    canvas = $('#tools_sketch')
    if $(this).is(':checked')
      canvas.css('background-image', 'none');
    else
      canvas.css('background-image', "url(#{app.img_url})");
        # $li    = $this.parents('li').toggleClass('done'),
        # isDone = $li.is('.done');
    #app.trigger('mark' + (isDone ? 'Done' : 'Undone'), { id: $li.attr('data-id') });

  
if VK?
  VK.init ->
    app.run('#/')
else
  app.run('#/')
