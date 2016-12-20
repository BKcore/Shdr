class App

  @UPDATE_ALL: 0
  @UPDATE_ENTER: 1
  @UPDATE_MANUAL: 2
  @FRAGMENT: 0
  @VERTEX: 1
  @UNIFORMS: 2

  constructor: (domEditor, domCanvas, conf={}) ->
    # CUSTOM THREE.JS HACK
    window.THREE_SHADER_OVERRIDE = true
    @initBaseurl()
    @documents = ['', '', '']
    @marker = null
    @viewer = null
    @validator = null
    @conf =
      update: App.UPDATE_ALL
      mode: App.FRAGMENT
    @extend(@conf, conf)
    @ui = new shdr.UI(@)
    return if not @initViewer(domCanvas)
    @initEditor(domEditor)
    @initFromURL()
    @byId(domEditor).addEventListener('keyup', ((e) => @onEditorKeyUp(e)), off)
    @byId(domEditor).addEventListener('keydown', ((e) => @onEditorKeyDown(e)), off)
    @ui.hideMainLoader()
    @loop()

  initBaseurl: ->
    url = window.location.href
    hash = url.indexOf('#')
    if hash > 0
      @baseurl = url.substr(0, hash)
    else
      @baseurl = url
    if @baseurl.substr(0, 6) is "chrome"
      @baseurl = "http://shdr.bkcore.com/"

  initViewer: (domCanvas) ->
    try
      @viewer = new shdr.Viewer(@byId(domCanvas), @)
      @validator = new shdr.Validator(@viewer.canvas)
    catch e
      console.warn e
      msg = "Unable to start Shdr. \n\nWebGL is either deactivated or not supported by your device or browser. \n\nWould you like to visit get.webgl.org for more info?"
      @ui.setStatus(msg,
        shdr.UI.WARNING)
      @ui.displayWebGLError()
      conf = confirm(msg)
      location.href = "http://get.webgl.org/" if conf
      return false
    return true

  initEditor: (domEditor) ->
    @documents[App.FRAGMENT] = @viewer.fs
    @documents[App.VERTEX] = @viewer.vs
    @documents[App.UNIFORMS] = shdr.Snippets.DefaultUniforms
    @editor = ace.edit(domEditor)
    @editor.setFontSize("16px")
    @editor.setShowPrintMargin(off)
    #@editor.setTheme("ace/theme/monokai")
    @editor.getSession().setTabSize(2)
    @editor.getSession().setMode("ace/mode/glsl")
    @editor.getSession().setUseWrapMode(on)
    @editor.getSession().setValue(@documents[@conf.mode])
    @editor.focus()

  loop: ->
    requestAnimationFrame(() => @loop())
    @update()

  update: ->
    @viewer.update()

  updateShader: ->
    session = @editor.getSession()
    session.removeMarker(@marker.id) if @marker?
    if @conf.mode is App.FRAGMENT
      type = shdr.Validator.FRAGMENT
    else if @conf.mode is App.UNIFORMS
      try
        newUniforms = session.getValue()
        @viewer.updateShader(newUniforms, App.UNIFORMS)
      catch e
        @ui.setStatus('Uniform compilation failed', shdr.UI.ERROR)
      return
    else
      type = shdr.Validator.VERTEX
    src = session.getValue()
    if not src
      @ui.setStatus('Shader cannot be empty',
        shdr.UI.WARNING)
      @marker = session.highlightLines(0, 0)
      return
    [ok, line, msg] = @validator.validate(src, type)
    if ok
      @viewer.updateShader(src, @conf.mode)
      @ui.setStatus('Shader successfully compiled',
        shdr.UI.SUCCESS)
    else
      line = Math.max(0, line-1)
      @marker = session.highlightLines(line, line)
      @ui.setStatus("Line #{line} : #{msg}",
        shdr.UI.ERROR)

  initFromURL: ->
    obj = @unpackURL()
    @initDocuments(obj)

  initDocuments: (obj) ->
    if obj and obj.documents
      @documents = obj.documents
      fs = @documents[App.FRAGMENT]
      vs = @documents[App.VERTEX]
      uniforms = @documents[App.UNIFORMS]
      [_fs, fl, fm] = @validator.validate(fs, shdr.Validator.FRAGMENT)
      [_vs, vl, vm] = @validator.validate(vs, shdr.Validator.VERTEX)
      @viewer.updateShader(uniforms, App.UNIFORMS)
      if _fs and _vs
        @viewer.updateShader(vs, App.VERTEX)
        @viewer.updateShader(fs, App.FRAGMENT)
        @editor.getSession().setValue(if @conf.mode is App.VERTEX then vs else fs)
        @ui.setMenuMode(App.FRAGMENT)
        @ui.setStatus("Shaders successfully loaded and compiled.",
          shdr.UI.SUCCESS)
      else if _vs
        @viewer.updateShader(vs, App.VERTEX)
        @setMode(App.FRAGMENT, true)
        @ui.setMenuMode(App.FRAGMENT)
        @ui.setStatus("Shaders loaded but Fragment could not compile. Line #{fl} : #{fm}",
          shdr.UI.WARNING)
      else if _fs
        @viewer.updateShader(fs, App.FRAGMENT)
        @setMode(App.VERTEX, true)
        @ui.setMenuMode(App.VERTEX)
        @ui.setStatus("Shaders loaded but Vertex could not compile. Line #{vl} : #{vm}",
          shdr.UI.WARNING)
      else
        @setMode(App.VERTEX, true)
        @ui.setMenuMode(App.VERTEX)
        @ui.setStatus("Shaders loaded but could not compile. Line #{vl} : #{vm}",
          shdr.UI.WARNING)
      @editor.focus()
      true
    else
      false

  packURL: ->
    try
      obj = 
        documents: @documents
        model: @viewer.currentModel
      json = JSON.stringify(obj)
      packed = window.btoa(RawDeflate.deflate(json))
      return @baseurl + '#1/' + packed
    catch e
      @ui.setStatus("Unable to pack document: #{e.getMessage?()}",
        shdr.UI.WARNING)

  unpackURL: ->
    return false if not window.location.hash
    try
      hash = window.location.hash.substr(1)
      version = hash.substr(0, 2)
      packed = hash.substr(2)
      json = RawDeflate.inflate(window.atob(packed))
      obj = JSON.parse(json)
      return obj
    catch e
      @ui.setStatus("Unable to unpack document: #{e.getMessage?()}",
        shdr.UI.WARNING)

  shortenURL: (url, callback) ->
    key = 'AIzaSyB46wUnmnZaPH9JkHlRizmsQw9W2SSx1x0'
    $.ajax
      url: "https://www.googleapis.com/urlshortener/v1/url?key=#{key}"
      type: 'POST'
      contentType: 'application/json'
      dataType: 'json'
      data:
        JSON.stringify(longUrl: url)
      success: (resp) =>
        if not resp or 'error' of resp or not 'id' of resp
          @ui.setStatus('An error occured while trying to shorten shared URL.',
            shdr.UI.WARNING)
          console.warn resp
          callback?(false, null, resp)
        else
          @ui.setStatus('Shared URL has been shortened.',
          shdr.UI.SUCCESS)
          callback?(true, resp.id, resp)
      error: (e) =>
        callback?(false, null, e)
        @ui.setStatus('URL shortening service is not active.',
            shdr.UI.WARNING)
        console.warn 'ERROR: ', e

  texture: (textureObj) ->
    try
      @ui.setStatus('Uploading...', shdr.UI.WARNING)
      reader = new FileReader()
      reader.readAsDataURL textureObj
      console.log(textureObj)
      reader.onload = (e) =>
        console.log("onload happened")
        texture = {name: textureObj.name, data: e.target.result}
        shdr.Textures[texture.name] = texture
        @ui.setStatus('Uploaded', shdr.UI.SUCCESS)
    catch e
      @ui.setStatus('You must select a texture to upload.', shdr.UI.WARNING)

  upload: (fileObj) ->
    try
      @ui.setStatus('Uploading...', shdr.UI.WARNING)
      reader = new FileReader()
      reader.readAsDataURL fileObj
      reader.onload = (e) =>
        model = {name: fileObj.name.split('.')[0], data: e.target.result}
        shdr.Models[e.target.result] = model
        @ui.setStatus('Uploaded', shdr.UI.SUCCESS)
        @ui.addNewModel(fileObj.name, e.target.result)
     catch e
       @ui.setStatus('You must select a .js model to upload.', shdr.UI.WARNING)

  download: ->
    try
      blob = new Blob(["#ifdef VS \n \n" + @documents[App.VERTEX] + "\n \n#else \n \n" + @documents[App.FRAGMENT] + "\n \n#endif"],
        type: 'text/plain')
      url = URL.createObjectURL(blob)
      win = window.open(url, '_blank')
      if win
        win.focus()
      else
        @ui.setStatus('Your browser as blocked the download, please disable popup blocker.',
        shdr.UI.WARNING)
    catch e
      @ui.setStatus('Your browser does not support Blob, unable to download.',
        shdr.UI.WARNING)
    url

  save: (name) ->
    @updateDocument()
    obj =
      documents: @documents
      name: name
      date: +Date.now()
    shdr.Storage.addDocument(name, obj)
    @ui.resetLoadFiles()
    @ui.setStatus("Shaders saved as '#{name}'.",
      shdr.UI.SUCCESS)

  load: (name) ->
    obj = shdr.Storage.getDocument(name)
    if obj?
      @initDocuments(obj)
      true
    else
      @ui.setStatus("'#{name}' Shaders do not exist.",
        shdr.UI.WARNING)
      false

  new: ->
    obj =
      documents: [
        shdr.Snippets.DefaultFragment
        shdr.Snippets.DefaultVertex
        shdr.Snippets.DefaultUniforms
      ]
      name: 'Untitled'
    @initDocuments(obj)
    @ui.setStatus('Editor reset using default shaders.',
      shdr.UI.SUCCESS)
    @ui.clearName('Untitled')
    loadModel('models/suzanne_high.js')

  newDemo: ->
    obj =
      documents: [
        shdr.Snippets.DemoFragment
        shdr.Snippets.DemoVertex
      ]
      name: 'Untitled'
    @initDocuments(obj)
    @ui.setStatus('Editor reset using default shaders.',
      shdr.UI.SUCCESS)
    @ui.clearName('Untitled')
    @viewer.loadModel('models/quad.js')

  remove: (name, reset=false) ->
    removed = shdr.Storage.removeDocument(name)
    if removed
      @new() if reset
      @ui.resetLoadFiles()
      @ui.setStatus("'#{name}' Shaders removed.",
        shdr.UI.INFO)
    else
      @ui.setStatus("Unable to remove '#{name}'. Shaders do not exist.",
        shdr.UI.WARNING)

  updateDocument: ->
    @documents[@conf.mode] = @editor.getSession().getValue()

  onEditorKeyUp: (e) ->
    key = e.keyCode
    proc = @conf.update is App.UPDATE_ENTER and key is 13
    proc or= @conf.update is App.UPDATE_ALL
    @updateShader() if proc
    true

  onEditorKeyDown: (e) ->
    if e.ctrlKey and e.keyCode is 83
      @updateShader()
      e.cancelBubble = true
      e.returnValue = false
      e.stopPropagation?()
      e.preventDefault?()
      false
    else if e.ctrlKey and e.altKey # Flip Shader
      if @conf.mode is App.FRAGMENT
        @setMode(App.VERTEX,true)
        @ui.setMenuMode(App.VERTEX)
      else
        @setMode(App.FRAGMENT,true)
        @ui.setMenuMode(App.FRAGMENT)
      e.cancelBubble = true
      e.returnValue = false
      e.stopPropagation?()
      e.preventDefault?()
      false
    else
      true

  setUpdateMode: (mode) ->
    @conf.update = parseInt(mode)
    this

  setMode: (mode=App.FRAGMENT, force=false) ->
    mode = parseInt(mode)
    return false if @conf.mode is mode and not force
    old = @conf.mode
    @conf.mode = mode
    session = @editor.getSession()
    switch mode
      when App.FRAGMENT
        @documents[old] = session.getValue() if not force
        session.setValue(@documents[App.FRAGMENT])
      when App.VERTEX
        @documents[old] = session.getValue() if not force
        session.setValue(@documents[App.VERTEX])
      when App.UNIFORMS
        @documents[old] = session.getValue() if not force
        session.setValue(@documents[App.UNIFORMS])
    @updateShader()
    this

  byId: (id) ->
    document.getElementById(id)

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

@shdr ||= {}
@shdr.App = App
