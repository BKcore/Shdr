Snippets = 

	rim: [
    'vec3 rim(vec3 color, float start, float end, float coef)'
    '{'
    '  vec3 normal = normalize(fNormal);'
    '  vec3 eye = normalize(-fPosition.xyz);'
    '  float rim = smoothstep(start, end, 1.0 - dot(normal, eye));'
    '  return clamp(rim, 0.0, 1.0) * coef * color;'
    '}'
    ].join('\n')