class App

  @UPDATE_ALL: 0
  @UPDATE_ENTER: 1
  @UPDATE_MANUAL: 2

  constructor: (domEditor, domCanvas, conf={}) ->
    @marker = null
    @conf =
      update: App.UPDATE_ALL
    @extend(@conf, conf)
    @ui = new shdr.UI(@)
    @editor = ace.edit(domEditor)
    @editor.setFontSize("16px")
    @editor.setTheme("ace/theme/monokai")
    @editor.getSession().setTabSize(2)
    @editor.getSession().setMode("ace/mode/glsl")
    @editor.getSession().setUseWrapMode(on)
    @viewer = new shdr.Viewer(@byId(domCanvas))
    @validator = new shdr.Validator(@viewer.canvas)
    @editor.getSession().setValue(@viewer.fs)
    @editor.focus()
    @byId(domEditor).addEventListener('keyup', ((e) => @onEditorKeyUp(e)), off)
    @byId(domEditor).addEventListener('keydown', ((e) => @onEditorKeyDown(e)), off)
    @loop()

  loop: ->
    requestAnimationFrame(() => @loop())
    @update()

  update: ->
    @viewer.update()

  updateShader: ->
    session = @editor.getSession()
    session.removeMarker(@marker.id) if @marker?
    src = session.getValue()
    [ok, line, msg] = @validator.validate(src)
    if ok
      @viewer.updateShader(src)
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

  byId: (id) ->
    document.getElementById(id)

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  debug: () ->
    source = @editor.getSession().getValue()
    gl = @viewer.renderer.getContext()
    shader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource(shader, source)
    gl.compileShader(shader)
    log = gl.getShaderInfoLog(shader)
    @editor.getSession().setValue(log)
    #
    # marker = highlightLines(start, end, cssclass, front)
    # editSession.removeMarker(marker.id)

@shdr ||= {}
@shdr.App = App