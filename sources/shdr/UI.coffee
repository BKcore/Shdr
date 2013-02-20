class UI

  constructor: (@app) ->
    @initBehaviors()

  initBehaviors: ->
    $('.menu-trigger').on('click.on', (e) => @onMenuTrigger(e))
    $('.menu-item').on('click', (e) => @onMenuItem(e))

  onMenuTrigger: (event) ->
    el = $(event.target)
    root = el.parent()
    list = root.find('.menu-list')
    
    el.addClass('open')
    list.fadeIn()

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
    el.on('click.on', (e) => @onMenuTrigger(e))
    list.fadeOut()
    $(document).off('click.menu-trigger')

  onMenuItem: (event) ->
    item = $(event.target)
    list = item.parent()
    root = list.parent()
    el = root.find('.menu-trigger')
    index = item.attr('data-index')

    el.text(item.text())
    el.attr('data-index', index)
    @[root.attr('data-action')+'Action']?(index)
    @offMenuTrigger(el, list)
    event.stopPropagation()
    
  updateAction: (index) ->
     @app.setUpdateMode(index)

@shdr ||= {}
@shdr.UI = UI