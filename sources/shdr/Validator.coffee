class Validator

  @FRAGMENT: null
  @VERTEX: null

  constructor: (@canvas) ->
    @available = true
    if not @canvas
      @canvas = document.createElement('Canvas')
    try
      @context = @canvas.getContext("webgl") or
        @canvas.getContext("experimental-webgl")
    catch e
      console.log e
    if not @context
      @available = false
      console.warn 'GLSL Validator: No WebGL context.'
    else
      Validator.FRAGMENT = @context.FRAGMENT_SHADER
      Validator.VERTEX = @context.VERTEX_SHADER

  validate: (source, type=Validator.FRAGMENT) ->
    return [true, null, null] if not @available or not source
    try
      shader = @context.createShader(type)
      @context.shaderSource(shader, source)
      @context.compileShader(shader)
      status = @context.getShaderParameter(
        shader, @context.COMPILE_STATUS)
    catch e
      return [false, 0, e.getMessage]
    if status is true
      return [true, null, null]
    else
      log = @context.getShaderInfoLog(shader)
      @context.deleteShader(shader)
      lines = log.split('\n')
      for i in lines
        error = i if i.substr(0, 5) is 'ERROR'
      if not error
        return [false, 0, 'Unable to parse error.']
      details = error.split(':')
      if details.length < 4
        return [false, 0, error]
      line = details[2]
      message = details.splice(3).join(':')
      return [false, parseInt(line), message]

@shdr ||= {}
@shdr.Validator = Validator
