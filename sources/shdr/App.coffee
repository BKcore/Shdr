class App

  @UPDATE_ALL: 0
  @UPDATE_ENTER: 1
  @UPDATE_MANUAL: 2

  constructor: (domEditor, domCanvas, conf={}) ->
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
    @editor.getSession().setValue(@viewer.fs)
    @byId(domEditor).addEventListener('keyup', ((e) => @onEditorKey(e, false)), off)
    @byId(domEditor).addEventListener('keydown', ((e) => @onEditorKey(e, true)), off)
    @loop()

  loop: ->
    requestAnimationFrame(() => @loop())
    @update()

  update: ->
    @viewer.update()

  onEditorKey: (e, override) ->
    return if (override and @conf.update isnt App.UPDATE_MANUAL)
    return if (not override and @conf.update is App.UPDATE_MANUAL)
    [update, bubble] = @needsUpdate(e.keyCode, e.ctrlKey, e.altKey)
    if update
      @viewer.updateShader(@editor.getSession().getValue())
      if not bubble
        e.cancelBubble = true
        e.returnValue = false
        e.stopPropagation?()
        e.preventDefault?()
      bubble
    else
      true

  needsUpdate: (key, ctrl, alt) ->
    switch @conf.update
      when App.UPDATE_ENTER
        [key is 13, true] # Enter
      when App.UPDATE_MANUAL
        [ctrl and key is 83, false] # CTRL + S
      else
        [true, true]

  setUpdateMode: (mode) ->
    @conf.update = parseInt(mode)

  byId: (id) ->
    document.getElementById(id)

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

@shdr ||= {}
@shdr.App = App