Snippets = 

  'DefaultVertex': [
    'precision highp float;'
    'attribute vec3 position;'
    'attribute vec3 normal;'
    'uniform mat3 normalMatrix;'
    'uniform mat4 modelViewMatrix;'
    'uniform mat4 projectionMatrix;'
    'varying vec3 fNormal;'
    'varying vec3 fPosition;'
    ''
    'void main()'
    '{'
    '  fNormal = normalize(normalMatrix * normal);'
    '  vec4 pos = modelViewMatrix * vec4(position, 1.0);'
    '  fPosition = pos.xyz;'
    '  gl_Position = projectionMatrix * pos;'
    '}'
  ].join('\n')

  'DefaultFragment': [
    'precision highp float;'
    'uniform float time;'
    'uniform vec2 resolution;'
    'varying vec3 fPosition;'
    'varying vec3 fNormal;'
    ''
    'void main()'
    '{'
    '  gl_FragColor = vec4(fNormal, 1.0);'
    '}'
  ].join('\n')

  'Luma': [
    'vec3 luma = vec3(0.299, 0.587, 0.114);'
  ].join('\n')

  'Blinn-Phong (Dir)': [
    'vec2 blinnPhongDir(vec3 lightDir, float lightInt, float Ka, float Kd, float Ks, float shininess)'
    '{'
    '  vec3 s = normalize(lightDir);'
    '  vec3 v = normalize(-fPosition);'
    '  vec3 n = normalize(fNormal);' 
    '  vec3 h = normalize(v+s);'
    '  float diffuse = Ka + Kd * lightInt * max(0.0, dot(n, s));'
    '  float spec =  Ks * pow(max(0.0, dot(n,h)), shininess);'
    '  return vec2(diffuse, spec);'
    '}'
  ].join('\n')

  'ColorNormal': [
    'vec3 colorNormal(vec3 col1, vec3 col2, vec3 col3)'
    '{'
    '  vec3 n = normalize(fNormal);'
    '  return clamp(col1*n.x + col2*n.y + col3*n.z,'
    '              vec3(0.0), vec3(1.0));'
    '}'
  ].join('\n')

  'Rimlight': [
    'vec3 rim(vec3 color, float start, float end, float coef)'
    '{'
    '  vec3 normal = normalize(fNormal);'
    '  vec3 eye = normalize(-fPosition.xyz);'
    '  float rim = smoothstep(start, end, 1.0 - dot(normal, eye));'
    '  return clamp(rim, 0.0, 1.0) * coef * color;'
    '}'
  ].join('\n')

  'Split': [
    'vec3 split(vec3 left, vec3 right, float ratio, bool horizontal)'
    '{'
    '  float i = float(horizontal);'
    '  float m = i*gl_FragCoord.x/resolution.x;'
    '  m += (1.0-i)*gl_FragCoord.y/resolution.y;'
    '  float d = float(m < ratio);'
    '  return left*d + right*(1.0-d);'
    '}'
  ].join('\n')

@shdr ||= {}
@shdr.Snippets = Snippets
