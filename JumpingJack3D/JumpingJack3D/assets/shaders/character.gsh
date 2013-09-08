#version 150

uniform mat4 P;
uniform mat4 V;
uniform mat4 M;

uniform float time;

layout (triangles) in;
//layout (points) out;
layout (triangle_strip) out;
layout (max_vertices=200) out;

in float velocityMultiplier[];
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

/*
 const float cubeVertices[72] = float[72](
 1.0, -1.0,  1.0,
 1.0,  1.0,  1.0,
 -1.0, -1.0,  1.0,
 -1.0,  1.0,  1.0,
 
 1.0, -1.0, -1.0,
 1.0,  1.0, -1.0,
 -1.0, -1.0, -1.0,
 -1.0,  1.0, -1.0,
 
 -1.0, -1.0,  1.0,
 -1.0,  1.0,  1.0,
 -1.0, -1.0, -1.0,
 -1.0,  1.0, -1.0,
 
 1.0, -1.0,  1.0,
 1.0,  1.0,  1.0,
 1.0, -1.0, -1.0,
 1.0,  1.0, -1.0,
 
 1.0,  1.0, -1.0,
 1.0,  1.0,  1.0,
 -1.0,  1.0, -1.0,
 -1.0,  1.0,  1.0,
 
 1.0, -1.0, -1.0,
 1.0, -1.0,  1.0,
 -1.0, -1.0, -1.0,
 -1.0, -1.0,  1.0
 );
 */

vec3 v0, v1, v2;
vec3 cg;

const float gravity   = 0.00005;
const float velMul    = 2.5;
const float voxelSize = 0.04;


void makeVertex(vec4 vertex, vec2 color, vec4 position)
{
    iVectorV    = gVectorV[0];
    iVectorN    = gVectorN[0];
    iVectorL0   = gVectorL0[0];
    iVectorL1   = gVectorL1[0];
    iTexCoords0 = color;
    gl_Position = P * V * ( position + vertex * voxelSize);
    EmitVertex();
}

void makeCube(float s, float t)
{
    vec3 v = v0 + s * v1 + t * v2;
    float velocity = velocityMultiplier[0] * length(v - cg);
    vec3 np = normalize(cross(v1.xyz,v2.xyz));
    vec3 position = time * np * velocity;
    
    position.y -= gravity * time * time;
    
/*
    for (int i=0; i < gl_in.length(); i++) {
        vec4 new_pos = (gl_in[i].gl_Position + vec4(position, 0));
        if (new_pos.y < 0) {
            new_pos.y = 0.1;
        }
        gl_Position = P * V * new_pos;
        iVectorV    = vec4(s,t,0,0);
        
        EmitVertex();
    }
    
    EndPrimitive();
*/
    vec4 new_pos = gl_in[0].gl_Position + vec4(position, 0);
    
    if (new_pos.y < voxelSize/2) {
        new_pos.y = voxelSize/2;
    }
    
    vec2 color = vec2(s,t);
    
/*
    for (int i=0; i<24; i++) {
        iVectorV    = gVectorV[0];
        iVectorN    = gVectorN[0];
        iVectorL0   = gVectorL0[0];
        iVectorL1   = gVectorL1[0];
        iTexCoords0 = color;
            
        gl_Position = P * V * (new_pos + vec4(voxelSize * cubeVertices[3*i    ],
                                              voxelSize * cubeVertices[3*i + 1],
                                              voxelSize * cubeVertices[3*i + 2],
                                              0.0));
        EmitVertex();
        if (i%4 == 3) {
            EndPrimitive();
        }
    }
*/

    makeVertex(vec4( 1, -1,  1, 0), color, new_pos);
    makeVertex(vec4( 1,  1,  1, 0), color, new_pos);
    makeVertex(vec4(-1, -1,  1, 0), color, new_pos);
    makeVertex(vec4(-1,  1,  1, 0), color, new_pos);
    EndPrimitive();
    
    makeVertex(vec4( 1, -1, -1, 0), color, new_pos);
    makeVertex(vec4( 1,  1, -1, 0), color, new_pos);
    makeVertex(vec4(-1, -1, -1, 0), color, new_pos);
    makeVertex(vec4(-1,  1, -1, 0), color, new_pos);
    EndPrimitive();
    
    makeVertex(vec4(-1, -1,  1, 0), color, new_pos);
    makeVertex(vec4(-1,  1,  1, 0), color, new_pos);
    makeVertex(vec4(-1, -1, -1, 0), color, new_pos);
    makeVertex(vec4(-1,  1, -1, 0), color, new_pos);
    EndPrimitive();
    
    makeVertex(vec4( 1, -1,  1, 0), color, new_pos);
    makeVertex(vec4( 1,  1,  1, 0), color, new_pos);
    makeVertex(vec4( 1, -1, -1, 0), color, new_pos);
    makeVertex(vec4( 1,  1, -1, 0), color, new_pos);
    EndPrimitive();
    
    makeVertex(vec4( 1,  1, -1, 0), color, new_pos);
    makeVertex(vec4( 1,  1,  1, 0), color, new_pos);
    makeVertex(vec4(-1,  1, -1, 0), color, new_pos);
    makeVertex(vec4(-1,  1,  1, 0), color, new_pos);
    EndPrimitive();
    
    makeVertex(vec4( 1, -1, -1, 0), color, new_pos);
    makeVertex(vec4( 1, -1,  1, 0), color, new_pos);
    makeVertex(vec4(-1, -1, -1, 0), color, new_pos);
    makeVertex(vec4(-1, -1,  1, 0), color, new_pos);
    EndPrimitive();

}

void main() {
    
    if (time > 0.0) {
        // explosion geoshader
        v1  = (gl_in[1].gl_Position - gl_in[0].gl_Position).xyz;
        v2  = (gl_in[2].gl_Position - gl_in[0].gl_Position).xyz;
        v0  =  gl_in[0].gl_Position.xyz;
               
        cg = ( gl_in[0].gl_Position.xyz + gl_in[1].gl_Position.xyz + gl_in[2].gl_Position.xyz ) / 3.0;
            
        int numLayers = 1 << 0;

        float dt = 1.0 / float(numLayers);
        float t = 1.0;
               
        for ( int it = 0; it <= numLayers; it++) {
            
            float smax = 1.0 - t;
            int nums = it + 1;
            float ds = smax / float (nums - 1 );
            float s = 0.0;
           
            for (int is =0 ; is < nums; is++) {
                makeCube(s,t);
                s += ds;
            }
            t -= dt;
        }
    } else {
        //pass-through shader
        for (int i=0; i<gl_in.length(); i++) {
            gl_Position = P * V * gl_in[i].gl_Position;
            
            iVectorV    = gVectorV[i];
            iVectorN    = gVectorN[i];
            iVectorL0   = gVectorL0[i];
            iVectorL1   = gVectorL1[i];
            iTexCoords0 = gTexCoords0[i];

            EmitVertex();
        }
    }
}
