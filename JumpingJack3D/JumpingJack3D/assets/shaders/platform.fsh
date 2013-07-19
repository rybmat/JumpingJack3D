#version 150

uniform sampler2D textureMap0;

out vec4 pixelColor;

in vec4 iVectorV;
in vec4 iVectorN;
in vec4 iVectorL0;
in vec4 iVectorL1;
in vec2 iTexCoords0;

float shininess=50;

void main(void) {
	vec4 eyeVectorN = normalize(iVectorN);
	vec4 eyeVectorV = normalize(iVectorV);
	vec4 eyeVectorL0 = normalize(iVectorL0);
    vec4 eyeVectorL1 = normalize(iVectorL1);
    
	vec4 eyeVectorR0 = reflect(-eyeVectorL0, eyeVectorN);
    vec4 eyeVectorR1 = reflect(-eyeVectorL0, eyeVectorN);
    
	float nl0 = max(0,dot(eyeVectorL0, eyeVectorN));
    float nl1 = max(0,dot(eyeVectorL1, eyeVectorN));
	float nl = max(nl0, nl1);
    
    float rv0 = pow(max(0, dot(eyeVectorR0, eyeVectorV)), shininess);
    float rv1 = pow(max(0, dot(eyeVectorR1, eyeVectorV)), shininess);
    float rv = max(rv0, rv1);
    
	vec4 texColor0=texture(textureMap0, iTexCoords0);

    
	vec4 La = vec4(0,0,0,1);        //światło otoczenia
	vec4 Ma = vec4(0,0,0,1);        //materiał dla światła otoczenia
	vec4 Ld = vec4(1,1,1,1);        //światło rozpraszane
	vec4 Md = texColor0;            //materiał dla światła rozpraszanego
	vec4 Ls = vec4(1,1,1,0);        //światło odbijane
	vec4 Ms = vec4(1,1,1,1);        //materiał dla światła odbijanego
    
	pixelColor = La * Ma + Ld * Md * nl + Ls * Ms * rv;
}