class Storage

  @available: 'localStorage' of window

  @list: ->
    return [] if not Storage.available
    return localStorage.data

  @add: (name, obj, overwrite=true) ->
    return false if not Storage.available
    return false if name of localStorage.data and not overwrite
    key = name+""
    localStorage.data[key] = obj
    true

  @get: (name) ->
    return null if not Storage.available or not name of localStorage.data
    return localStorage.data[name]

  @clear: ->
    return if not Storage.available
    localStorage['data'] = {}

  @clearSettings: ->
    return if not Storage.available
    localStorage['settings'] = {}

if Storage.available
  if not 'settings' of localStorage
    Storage.clearSettings()
  if not 'data' of localStorage
    Storage.clear()

@shdr ||= {}
@shdr.Storage = Storage