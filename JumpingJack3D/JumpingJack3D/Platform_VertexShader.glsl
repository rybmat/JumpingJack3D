#version 150

uniform mat4 P;
uniform mat4 V;
uniform mat4 M;
uniform vec4 lp0;
uniform vec4 lp1;


in vec4 vertex;
in vec4 normal;
in vec4 texCoords0;


out vec4 iVectorV;
out vec4 iVectorN;
out vec4 iVectorL0;
out vec4 iVectorL1;
out vec4 iTexCoords0;

void main(void) {
	gl_Position=P*V*M*vertex;
	
    iVectorN = normalize(V*M*normal);               //znormalizowany wektor normalny w przestrzeni oka
	iVectorV = normalize(vec4(0,0,0,1)-V*M*vertex); //znormalizowany wektor do obserwatora w przestrzeni oka
	iVectorL0 = normalize(V*lp0-V*M*vertex);        //znormalizowany wektor do swiatla "0" w przestrzeni oka
    iVectorL1 = normalize(V*lp1-V*M*vertex);        //znormalizowany wektor do swiatla "1" w przestrzeni oka
	iTexCoords0 = texCoords0;
    
}