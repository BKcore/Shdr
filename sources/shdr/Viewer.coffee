class Viewer

  @FRAGMENT: 0
  @VERTEX: 1
  @UNIFORMS: 2

  constructor: (@dom, @app) ->
    @time = 0.0
    @rotate = false
    @currentModel = null
    @rotateRate = 0.005
    @renderer = new THREE.WebGLRenderer(antialias: on)
    @canvas = @renderer.domElement
    @dom.appendChild(@canvas)
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(35, @dom.clientWidth/@dom.clientHeight, 1, 3000)
    @controls = new THREE.OrbitControls(@camera, @dom)
    @scene.add(@camera)
    @loader = new THREE.JSONLoader()
    @material = @defaultMaterial()
    @loadModel('models/suzanne_high.js')
    @onResize()
    window.addEventListener('resize', (() => @onResize()), off)

  update: ->
    @controls.update()
    @time += 0.001
    @uniforms.time.value = @time
    @model.rotation.y += @rotateRate if @model and @rotate
    @renderer.render(@scene, @camera)

  reset: ->
    @model.rotation.y = 0

  onResize: ->
    if @camera
      @camera.aspect = @dom.clientWidth/@dom.clientHeight
      @camera.updateProjectionMatrix()
      @camera.position.z = 900/@dom.clientWidth*4
      @camera.lookAt(@scene.position)
    if @uniforms
      @uniforms.resolution.value.x = @dom.clientWidth
      @uniforms.resolution.value.y = @dom.clientHeight
    @renderer.setSize(@dom.clientWidth, @dom.clientHeight)

  loadModel: (key) ->
    @loader.load(key, (geo) => 
      @initModel(geo, key)
    )
    @app.ui.showModelLoader()

  initModel: (geo, key) ->
    @currentModel = key
    data = shdr.Models[key]
    if @model?
      old = @model.geometry
      @scene.remove(@model)
      old.dispose()
    @model = new THREE.Mesh(geo, @material)
    if data?
      @model.scale.set(data.scale, data.scale, data.scale) if data.scale?
    @scene.add(@model)
    @app.ui.hideModelLoader()

  updateShader: (shader, mode=Viewer.FRAGMENT) ->
    if mode is Viewer.FRAGMENT
      @fs = shader
      @material.fragmentShader = shader
    else if mode is Viewer.UNIFORMS
      # shader is object to be merged in
      @resetUniforms()
      @addCustomUniforms(@parseUniforms(shader))
      @material.uniforms = @uniforms
    else
      @vs = shader
      @material.vertexShader = shader
    @material.needsUpdate = true

  resetUniforms: ->
    @uniforms =
      time:
        type: 'f'
        value: @time
      resolution:
        type: 'v2'
        value: new THREE.Vector2(@dom.clientWidth, @dom.clientHeight)

  # Parses lines of uniforms in the form 'type id = value;'
  parseUniforms: (uniformStr) ->
    toParse = uniformStr.split(';')
    uniformObj = {}

    for line in toParse
      if (!line.length)
        continue

      tokens = line.trim().split(' ')
      type = tokens[0]
      name = tokens[1]
      value = tokens.slice(3).join('')
      
      uniform = {}

      # Get the type of the uniform
      if type == 'float'
        uniform['type'] = 'f'
        uniform['value'] = parseFloat(value)
      else if type == 'int'
        uniform['type'] = 'i'
        uniform['value'] = parseInt(value)
      else if type == 'bool'
        uniform['type'] = 'i'
        uniform['value'] = value == 'true' ? 1 : 0
      else if type == 'vec2'
        vectorVals = value.slice(5, value.length - 1).split(',').map(
          parseFloat)
        uniform['type'] = 'v2'
        uniform['value'] = new THREE.Vector2(vectorVals[0], vectorVals[1])
      else if type == 'vec3'
        vectorVals = value.slice(5, value.length - 1).split(',').map(
          parseFloat)
        uniform['type'] = 'v3'
        console.log(value)
        uniform['value'] = new THREE.Vector3(vectorVals[0], vectorVals[1],
          vectorVals[2])
      else if type == 'vec4'
        vectorVals = value[4:-1].split(', ').map(parseFloat)
        uniform['type'] = 'v4'
        uniform['value'] = new THREE.Vector4(vectorVals[0], vectorVals[1],
          vectorVals[2], vectorVals[3])
      else if type =='sampler2D'
        uniform['type'] = 't'
        # Remove quotes from string
        value = value.replace(/^"(.*)"$/, '$1')
        value = value.replace(/^"(.*)"$/, "$1")
        console.log(value.split('/'))
        # Hacky way to make demo work
        if value.split('/')[0] == 'textures'
          uniform['value'] = THREE.ImageUtils.loadTexture(value)
        else
          uniform['value'] = THREE.ImageUtils.loadTexture(shdr.Textures[value].data)
      uniformObj[name] = uniform

    return uniformObj

  addCustomUniforms: (uniformsObj) ->
    for key,value of uniformsObj
      if (uniformsObj.hasOwnProperty(key))
        @uniforms[key] = value

  defaultMaterial: ->
    @resetUniforms()
    @addCustomUniforms(@parseUniforms(shdr.Snippets.DefaultUniforms))
    @vs = shdr.Snippets.DefaultVertex
    @fs = shdr.Snippets.DefaultFragment
    console.log(@uniforms)
    return new THREE.ShaderMaterial(
      uniforms: @uniforms
      vertexShader: @vs
      fragmentShader: @fs
    )

@shdr ||= {}
@shdr.Viewer = Viewer
