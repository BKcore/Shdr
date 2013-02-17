class Viewer

	constructor: (domCanvas) ->
    @time = 0.0
    @dom = $('#'+domCanvas)
    @renderer = new THREE.WebGLRenderer(antialias: true)
    @onResize()
    @dom.append(@renderer.domElement)
    @material = @defaultMaterial()
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(35, @dom.width()/@dom.height(), 1, 3000)
    @camera.position.z = 10;
    @camera.lookAt(@scene.position)
    @controls = new THREE.OrbitControls(@camera)
    #controls.addEventListener( 'change', render );
    @scene.add(@camera)
    @loader = new THREE.JSONLoader()
    @loadModel('models/monkey_mid.js')
    window.addEventListener('resize', (() => @onResize()), off);

  update: ->
    @controls.update()
    @time += 0.001
    @uniforms.time.value = @time
    @model.rotation.y = @time*5 if @model
    @renderer.render(@scene, @camera)

  onResize: ->
    if @camera
      @camera.aspect = @dom.width()/@dom.height()
      @camera.updateProjectionMatrix();
    @renderer.setSize(@dom.width(), @dom.height())

  loadModel: (path) ->
    @loader.load(path, ((g) => @addModel(g)))

  addModel: (geo) ->
    @model = new THREE.Mesh(geo, @material)
    @scene.add(@model)

  updateShader: (fs) ->
    @material.fragmentShader = fs
    @material.needsUpdate = true

  defaultMaterial: ->
    @uniforms = {
      time: {type: 'f', value: 0.0}
    }
    @vs = [
      'varying vec3 fNormal;'
      'varying vec4 fPosition;'
      'void main()'
      '{'
      'fNormal = normalMatrix * normal;'
      'fPosition = projectionMatrix * modelViewMatrix * vec4(position, 1.0);'
      'gl_Position = fPosition;'
      '}'
    ].join("\n")
    @fs = [
      'varying vec3 fNormal;'
      'varying vec4 fPosition;'
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