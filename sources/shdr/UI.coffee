class UI

  @ERROR: 0
  @SUCCESS: 1
  @WARNING: 2
  @INFO: 3

  constructor: (@app) ->
    @initStatus()
    @initSnippets()
    @initModels()
    @initMenus()
    @initToggles()
    @initButtons()
    @initBoxes()
    @resetLoadFiles()

  hideMainLoader: ->
    $('#main-loader').fadeOut(400)

  showModelLoader: ->
    $('#model-loader').fadeIn(200)

  hideModelLoader: ->
    $('#model-loader').fadeOut(400)

  displayWebGLError: ->
    $('#main-loader div').text('WebGL support missing.')

  clearName: (defaultName) ->
    @inputs.savename.val(defaultName)
    menuname = $('#menu-name')
    if menuname.is(':visible')
      menuname.fadeOut(200)
      $('#menu-remove').fadeOut(200)

  resetLoadFiles: ->
    tpl = ""
    for d in shdr.Storage.listDocuments()
      tpl += "<button type='button' class='menu-item' data-index='#{d}'>#{d}</button>\n"
    @lists.files.html(tpl)

  initStatus: ->
    el = $('#status')
    span = el.children('span')
    icon = span.children('i')
    content = span.children('b')
    @status = 
      container: el
      span: span
      icon: icon
      content: content

  initBoxes: ->
    @boxes =
      upload: $('#box-upload')
      texture: $('#box-texture')
      share: $('#box-share')
      about: $('#box-about')
    $('.box .close').on 'click', (e) ->
      $(this).parent().fadeOut(200)
    objFile = @boxes.upload.find('#box-upload-input')
    submitbutton = @boxes.upload.find('#box-upload-submit')
    submitbutton.on 'click', (e) =>
       inputFile = objFile[0].files[0]
       @app.upload(inputFile)
       @boxes.upload.fadeOut(200)
    texfile = @boxes.texture.find('#box-texture-input')
    submitbutton = @boxes.texture.find('#box-texture-submit')
    submitbutton.on 'click', (e) =>
       inputTexture = texfile[0].files[0]
       console.log(inputTexture)
       @app.texture(inputTexture)
       @boxes.texture.fadeOut(200)
    shareurl = @boxes.share.find('#box-share-url')
    shortenurl = @boxes.share.find('#box-share-shorten')
    shareurl.on 'click', (e) ->
      $(this).select()
    shortenurl.on 'click', (e) =>
      shortenurl.text('Wait...')
      @app.shortenURL shareurl.val(), (status, url, resp) =>
        if status and url
          @boxes.share.find('#box-share-url').val(url)
        shortenurl.text('Shorten')

  initButtons: ->
    @inputs =
      savename: $('#save-name')
    @inputs.savename.on 'click', (e) =>
      e.stopPropagation()
      $(this).focus()
      false
    $('.menu-button').on('click', (e) => @onButton(e))

  initToggles: ->
    $('.menu-toggle').on('click', (e) => @onToggle(e))

  initMenus: ->
    $('.menu-trigger').on('click.on', (e) => @onMenuTrigger(e))
    $(document).on('click', '.menu-item', (e) => @onMenuItem(e))
    @lists =
      files: $('#menu-load .menu-list')
      models: $('#menu-models .menu-list')

  initSnippets: ->
    list = $('#menu-snippets .menu-list')
    button = $('<button>').addClass('menu-item')
    for key of shdr.Snippets
      list.append(button.clone().text(key))
    no

  initModels: ->
    list = $('#menu-models .menu-list')
    button = $('<button>').addClass('menu-item')
    for key, model of shdr.Models
      list.append(button.clone().text(model.name)
      .attr('data-index', key))
    no

  addNewModel: (modelName, key) ->
    list = $('#menu-models .menu-list')
    button = $('<button>').addClass('menu-item')
    list.append(button.clone().text(modelName.charAt(0).toUpperCase() + modelName.split('.')[0].slice(1))
    .attr('data-index', key))

  setStatus: (message, type=UI.ERROR) ->
    @status.span.removeClass()
    @status.icon.removeClass()
    switch type
      when UI.ERROR
        @status.span.addClass('status-error')
        @status.icon.addClass('icon-exclamation-sign')
      when UI.SUCCESS
        @status.span.addClass('status-success')
        @status.icon.addClass('icon-ok-sign')
      when UI.WARNING
        @status.span.addClass('status-warning')
        @status.icon.addClass('icon-warning-sign')
      when UI.INFO
        @status.span.addClass('status-info')
        @status.icon.addClass('icon-info-sign')
    @status.content.text(message)

  setMenuMode: (mode) ->
    el = $('#menu-mode')
    item = el.find("button[data-index=#{mode}]")
    if item
      el.find('.menu-trigger').children('span')
      .text(item.text())
    mode

  onToggle: (event) ->
    el = $(event.target)
    root = el.parent()
    ico = el.children('i')
    state = el.attr('data-current') is el.attr('data-off')
    if state is on
      el.attr('data-current', el.attr('data-on'))
      ico.removeClass(ico.attr('data-off'))
      ico.addClass(ico.attr('data-on'))
    else
      el.attr('data-current', el.attr('data-off'))
      ico.removeClass(ico.attr('data-on'))
      ico.addClass(ico.attr('data-off'))
    @[root.attr('data-action')+'Action']?(state, null, el)
    @app.editor.focus()

  onButton: (event) ->
    el = $(event.target)
    root = el.parent()
    @[root.attr('data-action')+'Action']?(null, null, el)
    el.blur()

  onMenuTrigger: (event) ->
    el = $(event.target)
    root = el.parent()
    list = root.children('.menu-list')
    
    el.addClass('open')
    list.slideDown(200)

    $(document).on 'click.menu-trigger', () => 
      @offMenuTrigger(el, list)

    el.off('click.on')
    el.on 'click.off', (e) =>
      @offMenuTrigger(el, list)

    event.stopPropagation()

  offMenuTrigger: (el, list) ->
    el.removeClass('open')
    el.off('click.off')
    el.blur()
    el.on('click.on', (e) => @onMenuTrigger(e))
    list.slideUp(200)
    $(document).off('click.menu-trigger')
    @app.editor.focus()

  onMenuItem: (event) ->
    item = $(event.target)
    list = item.parent()
    root = list.parent()
    el = root.children('.menu-trigger')
    index = item.attr('data-index')

    @[root.attr('data-action')+'Action']?(index, item, el)
    @offMenuTrigger(el, list)
    event.stopPropagation()
    
  updateAction: (index, item, trigger) ->
    trigger.html(item.html())
    @app.setUpdateMode(index)

  snippetsAction: (index, item, trigger) ->
    code = shdr.Snippets[item.text()]
    @app.editor.insert(code) if code?

  modelsAction: (index, item, trigger) ->
    trigger.children('span').text(item.text())
    @app.viewer.loadModel(index)

  modeAction: (index, item, trigger) ->
    trigger.children('span').text(item.text())
    @app.setMode(index)

  rotateAction: (state) ->
    @app.viewer.rotate = state

  resetAction: ->
    @app.viewer.reset()

  shareAction: ->
    @app.updateDocument()
    url = @app.packURL()
    @boxes.share.find('#box-share-url').val(url)
    @boxes.share.fadeIn(200)

  uploadAction: ->
    @app.updateDocument()
    boxupload = $('#box-upload')
    @boxes.upload.fadeIn(200)

  textureAction: ->
    @app.updateDocument()
    boxupload = $('#box-texture')
    @boxes.texture.fadeIn(200)

  downloadAction: ->
    @app.download()

  aboutAction: ->
    @boxes.about.fadeIn(200)

  helpAction: ->
    win = window.open('https://github.com/BKcore/Shdr/wiki/Help',
      '_blank')
    if win
      win.focus()
    else
      @ui.setStatus('Your browser as blocked the Help window, please disable your popup blocker.',
      shdr.UI.WARNING)

  saveAction: (_,__,el) ->
    menuname = $('#menu-name')
    if not menuname.is(':visible')
      menuname.fadeIn(200)
      $('#menu-remove').fadeIn(200)
      @inputs.savename.val('Untitled')
      @setStatus('Please enter a file name, then hit the save button once again.', UI.INFO)
    else
      @app.save(@inputs.savename.val())

  loadAction: (index) ->
    exists = @app.load(index)
    console.log exists
    if exists
      @inputs.savename.val(index)
      menuname = $('#menu-name')
      if not menuname.is(':visible')
        menuname.fadeIn(200)
        $('#menu-remove').fadeIn(200)

  newAction: (confirm) ->
    if confirm is "default"
      @app.new()
    else if confirm is "demo"
      @app.newDemo()

  
  removeAction: (confirm) ->
    if confirm is "confirm"
      @app.remove(@inputs.savename.val(), true)

@shdr ||= {}
@shdr.UI = UI
