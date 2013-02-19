class Viewer

  constructor: (@dom) ->
    @time = 0.0
    @renderer = new THREE.WebGLRenderer(antialias: true)
    @dom.appendChild(@renderer.domElement)
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(35, @dom.clientWidth/@dom.clientHeight, 1, 3000)
    @controls = new THREE.OrbitControls(@camera, @dom)
    @scene.add(@camera)
    @loader = new THREE.JSONLoader()
    @material = @defaultMaterial()
    @loadModel('models/hexmkii.js')
    @onResize()
    window.addEventListener('resize', (() => @onResize()), off)

  update: ->
    @controls.update()
    @time += 0.001
    @uniforms.time.value = @time
    @model.rotation.y = @time*5 if @model
    @renderer.render(@scene, @camera)

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

  loadModel: (path) ->
    @loader.load(path, ((g) => @addModel(g)))

  addModel: (geo) ->
    @model = new THREE.Mesh(geo, @material)
    @scene.add(@model)

  updateShader: (fs) ->
    @fs = fs
    @material.fragmentShader = fs
    @material.needsUpdate = true

  defaultMaterial: ->
    @uniforms = {
      time: {type: 'f', value: 0.0},
      camera: {type: 'v3', value: @camera.position}
      resolution: {type: 'v2', value: new THREE.Vector2(@dom.clientWidth, @dom.clientHeight)}
    }
    @vs = [
      'uniform vec3 camera;'
      'varying vec3 fCamera;'
      'varying vec3 fNormal;'
      'varying vec3 fPosition;'
      'varying vec3 fVPosition;'
      'void main()'
      '{'
      'fNormal = normalMatrix * normal;'
      'fPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;'
      'fVPosition = position;'
      'fCamera = (modelMatrix * vec4(camera, 1.0)).xyz;'
      'gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);'
      '}'
    ].join("\n")
    @fs = [
      'uniform float time;'
      'varying vec3 fPosition;'
      'varying vec3 fNormal;'
      'varying vec3 fCamera;'
      'void main()'
      '{'
      '  gl_FragColor = vec4(fNormal, 1.0);'
      '}'
    ].join("\n")
    return new THREE.ShaderMaterial(
      uniforms: @uniforms
      vertexShader: @vs
      fragmentShader: @fs
    )

@shdr ||= {}
@shdr.Viewer = Viewer