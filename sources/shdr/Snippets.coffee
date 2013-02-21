Snippets = 

	'Luma': 'vec3 luma = vec3(0.299, 0.587, 0.114);'

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