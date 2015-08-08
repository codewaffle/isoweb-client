precision highp float;

#pragma glslify: transform = require(glsl-lut)

varying vec2 vTextureCoord;
varying vec4 vColor;

uniform sampler2D uSampler;

uniform sampler2D nightLut;
uniform sampler2D morningLut;
uniform sampler2D fireLut;

void main(void)
{
   vec2 uvs = vTextureCoord.xy;

   vec4 fg = texture2D(uSampler, vTextureCoord);


   gl_FragColor = transform(fg, morningLut);

}