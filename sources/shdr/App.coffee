class App

  @UPDATE_ALL: 1
  @UPDATE_ENTER: 2
  @UPDATE_MANUAL: 3

  constructor: (domEditor, domCanvas, conf={}) ->
    @conf =
      update: App.UPDATE_ALL
    @extend(@conf, conf)
    @editor = ace.edit(domEditor)
    @editor.setFontSize("16px")
    @editor.setTheme("ace/theme/monokai")
    @editor.getSession().setTabSize(2)
    @editor.getSession().setMode("ace/mode/glsl")
    @viewer = new shdr.Viewer(domCanvas)
    @editor.getSession().setValue(@viewer.fs)
    eventType = if @conf.update is App.UPDATE_MANUAL then 'keydown' else 'keyup'
    @byId(domEditor).addEventListener(eventType, ((e) => @onEditorKey(e)), off)
    @loop()

  loop: ->
    requestAnimationFrame(() => @loop())
    @update()

  update: ->
    @viewer.update()

  onEditorKey: (e) ->
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

  byId: (id) ->
    document.getElementById(id)

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

@shdr ||= {}
@shdr.App = App