class App

  @UPDATE_ALL: 0
  @UPDATE_ENTER: 1
  @UPDATE_MANUAL: 2
  @FRAGMENT: 0
  @VERTEX: 1

  constructor: (domEditor, domCanvas, conf={}) ->
    # CUSTOM THREE.JS HACK
    window.THREE_SHADER_OVERRIDE = true
    @documents = ['', '']
    @marker = null
    @conf =
      update: App.UPDATE_ALL
      mode: App.FRAGMENT
    @extend(@conf, conf)
    @ui = new shdr.UI(@)
    @viewer = new shdr.Viewer(@byId(domCanvas))
    @validator = new shdr.Validator(@viewer.canvas)
    @initEditor(domEditor)
    @byId(domEditor).addEventListener('keyup', ((e) => @onEditorKeyUp(e)), off)
    @byId(domEditor).addEventListener('keydown', ((e) => @onEditorKeyDown(e)), off)
    @loop()

  initEditor: (domEditor) ->
    @documents[App.FRAGMENT] = @viewer.fs
    @documents[App.VERTEX] = @viewer.vs
    @editor = ace.edit(domEditor)
    @editor.setFontSize("16px")
    @editor.setTheme("ace/theme/monokai")
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
    else
      type = shdr.Validator.VERTEX
    src = session.getValue()
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

  onEditorKeyUp: (e) ->
    key = e.keyCode
    proc = @conf.update is App.UPDATE_ENTER and key is 13
    proc or= @conf.update is App.UPDATE_ALL
    @updateShader() if proc
    true

  onEditorKeyDown: (e) ->
    return true if @conf.update isnt App.UPDATE_MANUAL
    if e.ctrlKey and e.keyCode is 83
      @updateShader()
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

  setMode: (mode=App.FRAGMENT) ->
    return false if @conf.mode is mode
    old = @conf.mode
    @conf.mode = mode
    session = @editor.getSession()
    switch mode
      when App.FRAGMENT
        @documents[old] = session.getValue()
        session.setValue(@documents[App.FRAGMENT])
      when App.VERTEX
        @documents[old] = session.getValue()
        session.setValue(@documents[App.VERTEX])
    this

  byId: (id) ->
    document.getElementById(id)

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

@shdr ||= {}
@shdr.App = App