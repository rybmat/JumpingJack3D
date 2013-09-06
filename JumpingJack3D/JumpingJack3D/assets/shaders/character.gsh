#version 150

uniform mat4 P;
uniform mat4 V;
uniform mat4 M;

uniform float time;

layout (triangles) in;
layout (triangle_strip) out;
layout (max_vertices=4) out;

in vec4 gVectorV[];
in vec4 gVectorN[];
in vec4 gVectorL0[];
in vec4 gVectorL1[];
in vec2 gTexCoords0[];

out vec4 iVectorV;
out vec4 iVectorN;
out vec4 iVectorL0;
out vec4 iVectorL1;
out vec2 iTexCoords0;

void main(void) {
     
	vec4 v0 = gl_in[0].gl_Position;
	vec4 v1 = gl_in[1].gl_Position;
	vec4 v2 = gl_in[2].gl_Position;
    
	vec4 ap = v1-v0;
	vec4 bp = v2-v0;
    
	vec3 np = normalize(cross(bp.xyz,ap.xyz));
     
    vec4 n = vec4(np,0);
    
	int i;
	
	for (i=0; i < gl_in.length(); i++) {
		gl_Position = P * V * M * (gl_in[i].gl_Position + time * n);
        iVectorV    = gVectorV[i];
        iVectorN    = gVectorN[i];
        iVectorL0   = gVectorL0[i];
        iVectorL1   = gVectorL1[i];
        iTexCoords0 = gTexCoords0[i];
		EmitVertex();
	}
    
	gl_Position = P * V * M * (gl_in[0].gl_Position + time * n) ;
    iVectorV    = gVectorV[0];
    iVectorN    = gVectorN[0];
    iVectorL0   = gVectorL0[0];
    iVectorL1   = gVectorL1[0];
    iTexCoords0 = gTexCoords0[0];

	EmitVertex();
    
	EndPrimitive();
}