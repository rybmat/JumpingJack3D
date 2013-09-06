#version 150

uniform mat4 P;
uniform mat4 V;
uniform mat4 M;

uniform float time;

layout (triangles) in;
layout (triangle_strip) out;
layout (max_vertices=200) out;

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

vec3 v0, v1, v2;
vec3 cg;

void makeVertex(float s, float t)
{
    vec3 v = v0 + s * v1 + t * v2;
    float velocity = .2 * length(v - cg);
    vec3 np = normalize(cross(v1.xyz,v2.xyz));
    vec3 position = time * np * velocity;
    position.y -=0 *  time * time;
    
    for (int i=0; i < gl_in.length(); i++) {
        gl_Position = P * V * M *(gl_in[i].gl_Position + vec4(position, 0));
        iVectorV    = gVectorV[i];
        iVectorN    = gVectorN[i];
        iVectorL0   = gVectorL0[i];
        iVectorL1   = gVectorL1[i];
        iTexCoords0 = gTexCoords0[i];
        EmitVertex();
    }
    gl_Position = P * V * M *(gl_in[0].gl_Position + vec4(position, 0)) ;
    iVectorV    = gVectorV[0];
    iVectorN    = gVectorN[0];
    iVectorL0   = gVectorL0[0];
    iVectorL1   = gVectorL1[0];
    iTexCoords0 = gTexCoords0[0];
    
    EmitVertex();
    
    EndPrimitive();
}

void main() {
    v1  = (gl_in[1].gl_Position - gl_in[0].gl_Position).xyz;
    v2  = (gl_in[2].gl_Position - gl_in[0].gl_Position).xyz;
    v0  =  gl_in[0].gl_Position.xyz;
           
    cg = ( gl_in[0].gl_Position.xyz + gl_in[1].gl_Position.xyz + gl_in[2].gl_Position.xyz ) / 3.0;
        
    int numLayers = 1 << 5;

           float dt = 1.0 / float(numLayers);
           float t = 1.0;
           
           for ( int it = 0; it <= numLayers; it++) {
               float smax = 1.0 - t;
               int nums = it + 1;
               float ds = smax / float (nums - 1 );
               float s = 0.0;
               
               for (int is =0 ; is < nums; is++) {
                   makeVertex(s,t);
                   s += ds;
               }
           }
           
           t -= dt;
}


/*
void main(void) {
    
    const int levels  = 3;
    const float gravity = 0.2;
    
    vec4 v0 = gl_in[0].gl_Position;
	vec4 v1 = gl_in[1].gl_Position;
	vec4 v2 = gl_in[2].gl_Position;
    
	vec4 ap = v1-v0;
	vec4 bp = v2-v0;
    
	vec3 np = normalize(cross(ap.xyz,bp.xyz));
    
    vec3 position = time * np;
    position.y -= time * time * 0.2;

    vec4 n = vec4(position,0);
    
    int i;
    
    for (int j=0; j < levels; ++j) {
        
        float toCenter = 1.0 / levels;
        
        for (i=0; i < gl_in.length(); i++) {
            gl_Position = P * V * (gl_in[i].gl_Position + n);
            iVectorV    = gVectorV[i];
            iVectorN    = gVectorN[i];
            iVectorL0   = gVectorL0[i];
            iVectorL1   = gVectorL1[i];
            iTexCoords0 = gTexCoords0[i];
            EmitVertex();
        }
        
        gl_Position = P * V * (gl_in[0].gl_Position + n) ;
        iVectorV    = gVectorV[0];
        iVectorN    = gVectorN[0];
        iVectorL0   = gVectorL0[0];
        iVectorL1   = gVectorL1[0];
        iTexCoords0 = gTexCoords0[0];
        
        EmitVertex();
        
        EndPrimitive();
    }
}
*/