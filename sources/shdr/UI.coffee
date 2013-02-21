class UI

  constructor: (@app) ->
    @initSnippets()
    @initModels()
    @initMenus()
    @initToggles()

  initToggles: ->
    $('.menu-toggle').on('click', (e) => @onToggle(e))

  initMenus: ->
    $('.menu-trigger').on('click.on', (e) => @onMenuTrigger(e))
    $('.menu-item').on('click', (e) => @onMenuItem(e))

  initSnippets: ->
    list = $('#menu-snippets .menu-list')
    button = $('<button>').addClass('menu-item')
    for key of shdr.Snippets
      list.append(button.clone().text(key))

  initModels: ->
    list = $('#menu-models .menu-list')
    button = $('<button>').addClass('menu-item')
    for key, model of shdr.Models
      list.append(button.clone().text(model.name)
      .attr('data-index', key))

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

  onMenuTrigger: (event) ->
    el = $(event.target)
    root = el.parent()
    list = root.children('.menu-list')
    
    el.addClass('open')
    list.slideDown(200)

    $(document).on('click.menu-trigger', () => 
      @offMenuTrigger(el, list)
    )
    el.off('click.on')
    el.on('click.off', (e) =>
      @offMenuTrigger(el, list)
    )
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

  rotateAction: (state) ->
    @app.viewer.rotate = state

@shdr ||= {}
@shdr.UI = UI