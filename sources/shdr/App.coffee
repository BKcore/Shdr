class App

  constructor: (domEditor, domCanvas) ->
    @editor = ace.edit(domEditor)
    @editor.setFontSize("16px")
    @editor.setTheme("ace/theme/monokai")
    @editor.getSession().setMode("ace/mode/glsl")
    @viewer = new shdr.Viewer(domCanvas)
    @editor.getSession().setValue(@viewer.fs)
    @loop()

  loop: ->
    requestAnimationFrame(() => @loop())
    @update()

  update: ->
    @viewer.update()

@shdr ||= {}
@shdr.App = App