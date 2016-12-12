class Viewer

  @FRAGMENT: 0
  @VERTEX: 1

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
    else
      @vs = shader
      @material.vertexShader = shader
    @material.needsUpdate = true

  defaultMaterial: ->
    @uniforms =
      time: 
        type: 'f'
        value: 0.0
      resolution:
        type: 'v2'
        value: new THREE.Vector2(@dom.clientWidth, @dom.clientHeight)
    @vs = shdr.Snippets.DefaultVertex
    @fs = shdr.Snippets.DefaultFragment
    return new THREE.ShaderMaterial(
      uniforms: @uniforms
      vertexShader: @vs
      fragmentShader: @fs
    )

@shdr ||= {}
@shdr.Viewer = Viewer
