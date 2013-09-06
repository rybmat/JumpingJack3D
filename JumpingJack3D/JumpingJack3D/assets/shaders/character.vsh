#version 150

//Zmienne jednorodne
uniform mat4 P;
uniform mat4 V;
uniform mat4 M;
uniform vec4 lp0;
uniform vec4 lp1;


//Atrybuty
in vec4 vertex;
in vec4 normal;
in vec2 texCoords0;


out vec4 gVectorV;
out vec4 gVectorN;
out vec4 gVectorL0;
out vec4 gVectorL1;
out vec2 gTexCoords0;

void main(void) {
	gl_Position = vertex;
	
    gVectorN = normalize(V*M*normal);               //znormalizowany wektor normalny w przestrzeni oka
	gVectorV = normalize(vec4(0,0,0,1)-V*M*vertex); //znormalizowany wektor do obserwatora w przestrzeni oka
	gVectorL0 = normalize(V*lp0-V*M*vertex);        //znormalizowany wektor do swiatla "0" w przestrzeni oka
    gVectorL1 = normalize(V*lp1-V*M*vertex);        //znormalizowany wektor do swiatla "1" w przestrzeni oka
	gTexCoords0 = texCoords0;
    
}