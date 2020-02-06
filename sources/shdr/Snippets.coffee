Snippets = 

  'DefaultVertex': [
    'precision highp float;'
    'attribute vec3 position;'
    'attribute vec3 normal;'
    'uniform mat3 normalMatrix;'
    'uniform mat4 modelViewMatrix;'
    'uniform mat4 projectionMatrix;'
    'uniform mat2 faceVertexUvs;'
    'varying vec3 fNormal;'
    'varying vec3 fPosition;'
    'varying vec2 vUv;'
    ''
    'void main()'
    '{'
    '  vUv = faceVertexUvs * vec2(1, 1);'
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
    'varying vec2 vUv;'
    'uniform vec3 testColor;'
    ''
    'void main()'
    '{'
    '  gl_FragColor = vec4(fNormal, 1.0);'
    '}'
  ].join('\n')

  'DefaultUniforms': [
    'vec3 testColor = vec3(0.0, 0.0, 1.0);'
    'sampler2D my_texture = "textures/beanie.jpg";'
  ].join('\n')

  'Texture': [
    'precision highp float;'
    'uniform float time;'
    'uniform vec2 resolution;'
    'varying vec3 fPosition;'
    'varying vec3 fNormal;'
    'uniform sampler2D my_texture;'
    ''
    'void main()'
    '{'
    '  vec4 color = texture2D(my_texture, vec2((0.4 * fNormal.x) + 0.6, (0.4 * fNormal.y) + 0.4));'
    '  gl_FragColor = vec4(color.x, color.y, color.z, 1.0);'
    '}'
  ].join('\n')

  'DemoVertex': [
    'precision highp float;'
    'attribute vec3 position;'
    ''
    'void main()'
    '{'
    '  gl_Position = vec4(position, 1.0);'
    '}' 
  ].join('\n')

  'DemoFragment': [
    'precision highp float;'
    ''
    'uniform float time;'
    'uniform vec2 resolution;'
    ''
    'uniform mat4 modelViewMatrix;'
    'uniform mat4 projectionMatrix;'
    ''
    'void main()'
    '{'
      '  vec2 pixel = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;'
      '  pixel.x *= resolution.x/resolution.y;'
      '  gl_FragColor = vec4(pixel,.0,1.);'
    '}'
  ].join('\n');

  'ExtractCameraPosition': [
    'vec3 ExtractCameraPos(mat4 a_modelView)'
    '{'
    '  mat3 rotMat =mat3(a_modelView[0].xyz,a_modelView[1].xyz,a_modelView[2].xyz);'
    '  vec3 d =  a_modelView[3].xyz;' 
    '  vec3 retVec = -d * rotMat;'
    '  return retVec;'
    '}'
  ].join('\n');

  'GetDirection': [
    'vec3 getDirection(vec3 origine, vec2 pixel)'
    '{'
    '  vec3 ww = normalize(vec3(0.0) - origine);'
    '  vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));'
    '  vec3 vv = normalize(cross(ww,uu));'
    '  return normalize( pixel.x*uu + pixel.y*vv + 1.5*ww );'
    '}'
  ].join('\n');
  
  'Luma': [
    'vec3 luma = vec3(0.299, 0.587, 0.114);'
  ].join('\n')

  'Fresnel' : [
    'float fresnel(float costheta, float fresnelCoef)'
    '{'
    '  return fresnelCoef + (1. - fresnelCoef) * pow(1. - costheta, 5.);'
    '}'
  ].join('\n')

  'Ashikhmin (Dir)' : [
    'float Ashikhmin(vec3 lightDir, vec3 viewDir,  vec3 normal, float exponent, float fresnelCoef)'
    '{'
    '  vec3 H = normalize(lightDir+viewDir);'
    '  float numerateur_s = ( exponent + 1.)/(8.*3.14159) * pow(dot(normal,H), exponent );'
    '  float denominateur_s = dot(lightDir,H)*(dot(normal,lightDir) + dot(normal, viewDir) - dot(normal, lightDir) * dot(normal, viewDir));'
    '  float K =  fresnel(dot(normal,lightDir), fresnelCoef) * ( numerateur_s / denominateur_s  ) ;'
    '  return K;'
    '}'
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

  'OrenNayard (Dir)' : [
    'float OrenNayarDir(vec3 lightDir, vec3 viewDir, vec3 normal, float exponent)'
    '{'
    '  float LdotN = dot(lightDir,normal);'
    '  float VdotN = dot(viewDir,normal);'
    '  float result = clamp( LdotN, 0. , 1.);'
    '  float soft_rim = clamp( 1. - VdotN/2., 0. , 1.);'
    '  float fakey = pow(1. - result * soft_rim , 2.);'
    '  float fakey_magic = 0.62;'
    '  fakey = fakey_magic - fakey*fakey_magic;'
    '  float K =  mix(result, fakey, exponent) ;'
    '  return K;'
    '}'
  ].join('\n');

  'Ward (Dir)' : [
    'float Ward(vec3 lightDir, vec3 viewDir, vec3 normal, float exponent)'
    '{'
    '    vec3 H = normalize(lightDir + viewDir);'
    '    float delta = acos(dot(H,normal));'
    '    float alpha2 = exponent * exponent;'
    '    float temp = exp(-pow(tan(delta), 2.) / (alpha2)) / (4. * 3.1415 * alpha2);'
    '    float temp2 = sqrt(dot(viewDir,normal) * dot(lightDir,normal));'
    '    float K = temp2 * temp;'
    '    return K;'
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

  'Transpose (mat3)' : [
    'mat3 transpose( mat3 m )'
    '{'
    '  mat3 ret = m;'
    '  ret[0][1] = m[1][0];'
    '  ret[0][2] = m[2][0];'
    '  ret[1][0] = m[0][1];'
    '  ret[1][2] = m[2][1];'
    '  ret[2][0] = m[0][2];'
    '  ret[2][1] = m[1][2];'
    '  return ret;'
    '}'
  ].join('\n')

@shdr ||= {}
@shdr.Snippets = Snippets
