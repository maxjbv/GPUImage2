varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

// http://www.tannerhelland.com/3643/grayscale-image-algorithm-vb6/
void main()
{
    highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    highp float grey = (textureColor.x * 0.299 + textureColor.y * 0.587 + textureColor.z * 0.114);
    
    gl_FragColor = vec4(grey, grey, grey, textureColor.w);
}
