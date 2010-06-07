uniform sampler2D texture;
uniform vec3 viewPos;
uniform vec3 viewNormal;

varying vec2 texture_coordinate;
varying vec3 Position;
varying vec4 vertColor;

void main()
{
	vec4 texcolor = texture2D(texture, texture_coordinate);

	vec4 color = texcolor;

	color.r = color.r * vertColor.r;
	color.g = color.g * vertColor.g;
	color.b = color.b * vertColor.b;
	
	if(color.a < (1.0 - vertColor.a)) {
		color.a = 0.0;
		color.r = 1.0;
		color.g = 1.0;
		color.b = 1.0;
	}
	
	gl_FragColor = color;
}