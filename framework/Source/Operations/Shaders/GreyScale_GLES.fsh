varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

// http://www.tannerhelland.com/3643/grayscale-image-algorithm-vb6/
void main()
{
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    float grey = (textureColor * 0.299 + textureColor * 0.587 + textureColor * 0.114);
    
    gl_FragColor = vec4(grey, grey, grey, textureColor.a);
    
}
