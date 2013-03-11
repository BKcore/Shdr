class Storage

  @PREFIX_SIZE: 4
  @DOC_PREFIX: 'doc_'
  @SET_PREFIX: 'set_'

  @available: 'localStorage' of window

  @addDocument: (name, obj, overwrite=true) ->
    @addObject(@DOC_PREFIX+name, obj, overwrite)

  @addSetting: (name, str, overwrite=true) ->
    @addString(@SET_PREFIX+name, str, overwrite)

  @addObject: (key, obj, overwrite=true) ->
    @addString(key, JSON.stringify(obj), overwrite)

  @addString: (key, str, overwrite=true) ->
    return false if localStorage[key]? and not overwrite
    localStorage[key] = str

  @getDocument: (name) ->
    return @getObject(@DOC_PREFIX+name)

  @getSetting: (name) ->
    return @getString(@SET_PREFIX+name)

  @getObject: (key) ->
    return JSON.parse(@getString(key))

  @getString: (key) ->
    return null if not localStorage[key]?
    return localStorage[key]

  @listDocuments: ->
    return @_listByPrefix(@DOC_PREFIX)

  @removeDocument: (name) ->
    @remove(@DOC_PREFIX+name)

  @removeSetting: (name) ->
    @remove(@SET_PREFIX+name)

  @remove: (key) ->
    if key of localStorage
      delete localStorage[key]
      true
    else
      false

  @clearDocuments: ->
    @_clearByPrefix(@DOC_PREFIX)

  @clearSettings: ->
    @_clearByPrefix(@SET_PREFIX)

  @_listByPrefix: (prefix) ->
    list = []
    for k of localStorage
      if k.substr(0, @PREFIX_SIZE) is prefix
        list.push(k.substr(@PREFIX_SIZE))
    list

  @_clearByPrefix: (prefix) ->
    list = @_listByPrefix(prefix)
    delete localStorage[prefix+e] for e in list
    list.length

@shdr ||= {}
@shdr.Storage = Storage