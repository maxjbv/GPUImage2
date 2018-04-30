#ifdef GL_ES
precision highp float;
#endif
/// Uniform variables.
uniform float sepiaValue;
uniform float noiseValue;
uniform float scratchValue;
uniform float innerVignetting;
uniform float outerVignetting;
uniform float randomValue;
uniform float timeLapse;
uniform float u_time;

uniform sampler2D inputImageTexture;

/// Varying variables.
varying highp vec2 textureCoordinate;

/// Computes the overlay between the source and destination colours.
highp vec3 Overlay (vec3 src, vec3 dst) {
    // if (dst <= ro) then: 2 * src * dst
    // if (dst > ro) then: 1 - 2 * (1 - dst) * (1 - src)
    return vec3((dst.x <= 0.5) ? (2.0 * src.x * dst.x) : (1.0 - 2.0 * (1.0 - dst.x) * (1.0 - src.x)), (dst.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - dst.y) * (1.0 - src.y)), (dst.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - dst.z) * (1.0 - src.z)));
}

/// 2D Noise by Ian McEwan, Ashima Arts.
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

float snoise (vec2 v) {
    const vec4 C = vec4(
                        0.211324865405187, // (3.0-sqrt(3.0))/6.0
                        0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626, // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    highp vec2 i = floor(v + dot(v, C.yy) );
    highp vec2 x0 = v - i + dot(i, C.xx);
    // Other corners
    highp vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    highp vec4 x12 = x0.xyxy + C.xxzz; x12.xy -= i1;
    // Permutations
    i = mod289(i);
    // Avoid truncation effects in permutation
    highp vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
    highp vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    highp vec3 x = 2.0 * fract(p * C.www) - 1.0;
    highp vec3 h = abs(x) - 0.5;
    highp vec3 ox = floor(x + 0.5);
    highp vec3 a0 = x - ox;
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    // Compute final noise value at P
    highp vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

/// Fragment shader entry.
void main() {
    
//    float sepiaValue = .5;
//    float noiseValue = .3;
//    float scratchValue = sin(u_time * 10.0) * 100.0;// 5.10;
//    float innerVignetting = 0.3;
//    float outerVignetting = .0;
//    float randomValue = sin(u_time * 10.0) * 10.0;
//    float timeLapse = sin(u_time * 5.0);
    
    highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

    highp vec2 vTexCoord = textureCoordinate.xy;
    
    // Sepia RGB value
    highp vec3 sepia = vec3(112.0 / 255.0, 66.0 / 255.0, 20.0 / 255.0);
    
    // Step 1: Convert to grayscale
    highp vec3 colour = textureColor.xyz;
    highp float gray = (colour.x + colour.y + colour.z) / 3.0;
    highp vec3 grayscale = vec3(gray);
    
    //     Step 2: Appy sepia overlay
    highp vec3 finalColour = Overlay(sepia, grayscale);
    
    // Step 3: Lerp final sepia colour
    finalColour = grayscale + sepiaValue * (finalColour - grayscale);
    
    // Step 4: Add noise
    highp float noise = snoise(vTexCoord * vec2(1024.0 + randomValue * 512.0, 1024.0 + randomValue * 512.0)) * 0.5;
    finalColour += noise * noiseValue;
    
    // Optionally add noise as an overlay, simulating ISO on the camera
    //highp vec3 noiseOverlay = Overlay(finalColour, highp vec3(noise));
    //finalColour = finalColour + noiseValue * (finalColour - noiseOverlay);
    
    // Step 5: Apply scratches
    if ( randomValue < scratchValue ) {
        // Pick a random spot to show scratches
        highp float dist = 1.0 / scratchValue;
        highp float d = distance(vTexCoord, vec2(randomValue * dist, randomValue * dist));
        if ( d < 0.4 ) {
            // Generate the scratch
            highp float xPeriod = 8.0;
            highp float yPeriod = 1.0;
            highp float pi = 3.141592;
            highp float phase = timeLapse;
            highp float turbulence = snoise(vTexCoord * 2.5);
            highp float vScratch = 0.5 + (sin(((vTexCoord.x * xPeriod + vTexCoord.y * yPeriod + turbulence)) * pi + phase) * 0.5);
            vScratch = clamp((vScratch * 10000.0) + 0.35, 0.0, 1.0);
            finalColour.xyz *= vScratch;
        }
    }
    
    // Step 6: Apply vignetting
    // Max distance from centre to corner is ~0.7. Scale that to 1.0.
    highp float d = distance(vec2(0.5, 0.5), vTexCoord) * 1.414213;
    highp float vignetting = clamp((outerVignetting - d) / (outerVignetting - innerVignetting), 0.0, 1.0);
    finalColour.xyz *= vignetting;
    
    //     Apply colour
    gl_FragColor.xyz = finalColour;
    gl_FragColor.w = 1.0;
}
