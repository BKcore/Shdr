Snippets = 

	'rim': [
    'vec3 rim(vec3 color, float start, float end, float coef)'
    '{'
    '  vec3 normal = normalize(fNormal);'
    '  vec3 eye = normalize(-fPosition.xyz);'
    '  float rim = smoothstep(start, end, 1.0 - dot(normal, eye));'
    '  return clamp(rim, 0.0, 1.0) * coef * color;'
    '}'
  ].join('\n')

  'split': [
    'vec3 split(vec3 left, vec3 right, float ratio, bool horizontal)'
    '{'
    '  int i = int(horizontal);'
    '  float m = i*gl_FragCoord.x/resolution.x + (1-i)*gl_FragCoord.y/resolution.y;'
    '  int d = int(m < ratio);'
    '  return left*d + right*(1-d);'
    '}'
  ].join('\n')

@shdr ||= {}
@shdr.Snippets = Snippets