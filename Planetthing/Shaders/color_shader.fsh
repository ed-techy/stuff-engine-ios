uniform lowp vec4 colorComponent;

void main()
{
    // Color of the texture by the color component.
    gl_FragColor = colorComponent;
}