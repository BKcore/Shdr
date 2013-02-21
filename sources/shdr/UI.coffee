class UI

  constructor: (@app) ->
    @initSnippets()
    @initMenus()

  initMenus: ->
    $('.menu-trigger').on('click.on', (e) => @onMenuTrigger(e))
    $('.menu-item').on('click', (e) => @onMenuItem(e))

  initSnippets: ->
    list = $('#menu-snippets .menu-list')
    button = $('<button>').addClass('menu-item')
    for key of shdr.Snippets
      list.append(button.clone().text(key))

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

@shdr ||= {}
@shdr.UI = UI