//
//  JJMesh.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/15/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJMesh.h"

@implementation JJMesh

- (id) init
{
    self = [super init];
    if (self) {
        _vertexCount  = 0;
        _normalsCount = 0;
        _uvCount      = 0;
        _faceCount    = 0;
        
        _vertices  = NULL;
        _uvs       = NULL;
        _normals   = NULL;
    }
    return self;
}

- (BOOL) loadModel:(NSString *)filePath
{
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    if (fileContents == nil) {
        NSLog(@"Mesh: loadModel: unable to open file %@", filePath);
        return NO;
    }
    
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    
    [self setCountsWithLines:lines];
    [self allocateBuffers];
    
    GLfloat* tempVertices = (GLfloat*)malloc(sizeof(float) * 3 * self.vertexCount);
    GLfloat* tempUVs      = (GLfloat*)malloc(sizeof(float) * 2 * self.uvCount);
    GLfloat* tempNormals  = (GLfloat*)malloc(sizeof(float) * 3 * self.normalsCount);
    
    GLuint* tempVertexIndices = (GLuint*)malloc(sizeof(GLuint) * 3 * self.faceCount);
    GLuint* tempUVIndices     = (GLuint*)malloc(sizeof(GLuint) * 3 * self.faceCount);
    GLuint* tempNormalIndices = (GLuint*)malloc(sizeof(GLuint) * 3 * self.faceCount);
    
    int vertexPos = 0, normalsPos = 0, uvPos = 0;
    int vertexIndicesPos = 0, normalIndicesPos = 0, uvIndicesPos = 0;
    
    for (NSString* line in lines) {
        // Parsing vertices
        if ([line hasPrefix:@"v "]) {
            NSString* lineTrunc = [line substringFromIndex:2];
            NSArray* lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            tempVertices[vertexPos  ] = [[lineVertices objectAtIndex:0] floatValue];
            tempVertices[vertexPos+1] = [[lineVertices objectAtIndex:1] floatValue];
            tempVertices[vertexPos+2] = [[lineVertices objectAtIndex:2] floatValue];
            vertexPos += 3;
        }
        // Parsing normals
        else if ([line hasPrefix:@"vn "])
        {
            NSString* lineTrunc = [line substringFromIndex:2];
            NSArray* lineNormals = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            tempNormals[normalsPos  ] = [[lineNormals objectAtIndex:0] floatValue];
            tempNormals[normalsPos+1] = [[lineNormals objectAtIndex:1] floatValue];
            tempNormals[normalsPos+2] = [[lineNormals objectAtIndex:2] floatValue];
            normalsPos += 3;
        }
        // Parsing texture coordinates
        else if ([line hasPrefix:@"vt"])
        {
            NSString* lineTrunc = [line substringFromIndex:2];
            NSArray* lineUVs = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            tempUVs[uvPos  ] = [[lineUVs objectAtIndex:0] floatValue];
            tempUVs[uvPos+1] = [[lineUVs objectAtIndex:1] floatValue];
            uvPos += 2;
        }
        // Parsing faces
        else if ([line hasPrefix:@"f "])
        {
            NSString* lineTrunc = [line substringFromIndex:2];
            NSArray* groups = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSArray* group1 = [groups[0] componentsSeparatedByString:@"/"];
            NSArray* group2 = [groups[1] componentsSeparatedByString:@"/"];
            NSArray* group3 = [groups[2] componentsSeparatedByString:@"/"];

            tempVertexIndices[vertexIndicesPos  ] = [[group1 objectAtIndex:0] intValue] - 1;
            tempVertexIndices[vertexIndicesPos+1] = [[group2 objectAtIndex:0] intValue] - 1;
            tempVertexIndices[vertexIndicesPos+2] = [[group3 objectAtIndex:0] intValue] - 1;
            
            tempUVIndices[uvIndicesPos  ] = [[group1 objectAtIndex:1] intValue] - 1;
            tempUVIndices[uvIndicesPos+1] = [[group2 objectAtIndex:1] intValue] - 1;
            tempUVIndices[uvIndicesPos+2] = [[group3 objectAtIndex:1] intValue] - 1;
            
            tempNormalIndices[normalIndicesPos  ] = [[group1 objectAtIndex:2] intValue] - 1;
            tempNormalIndices[normalIndicesPos+1] = [[group2 objectAtIndex:2] intValue] - 1;
            tempNormalIndices[normalIndicesPos+2] = [[group3 objectAtIndex:2] intValue] - 1;

            vertexIndicesPos += 3;
            uvIndicesPos     += 3;
            normalIndicesPos += 3;
        }
    }
    
    for (GLuint i=0; i<self.faceCount*3; ++i) {
        
        //Get indicies of its attributes
        GLuint vertexIndex = tempVertexIndices[i];
        GLuint normalIndex = tempNormalIndices[i];
        GLuint uvIndex     = tempUVIndices[i];
        
        //Get vertex of this index
        GLfloat vertex[3];
        vertex[0] = tempVertices[vertexIndex*3  ];
        vertex[1] = tempVertices[vertexIndex*3+1];
        vertex[2] = tempVertices[vertexIndex*3+2];
        
        //Get normal of this index
        GLfloat normal[3];
        normal[0] = tempNormals[normalIndex*3  ];
        normal[1] = tempNormals[normalIndex*3+1];
        normal[2] = tempNormals[normalIndex*3+2];
        
        //Get UV of this index
        GLfloat uv[2];
        uv[0] = tempUVs[uvIndex*2  ];
        uv[1] = tempUVs[uvIndex*2+1];
        
        //Place vertex in new buffer
        _vertices[3*i  ] = vertex[0];
        _vertices[3*i+1] = vertex[1];
        _vertices[3*i+2] = vertex[2];
        
        //Place normal in new buffer
        _normals[3*i  ] = normal[0];
        _normals[3*i+1] = normal[1];
        _normals[3*i+2] = normal[2];
        
        //Place uv in new buffer
        _uvs[2*i  ] = uv[0];
        _uvs[2*i+1] = uv[1];
    }
    
    free(tempVertices);
    free(tempUVs);
    free(tempNormals);
    
    free(tempVertexIndices);
    free(tempUVIndices);
    free(tempNormalIndices);
    
    return YES;
}

- (void) setCountsWithLines:(NSArray*) lines
{
    for (NSString* line in lines) {
        if ([line hasPrefix:@"v "]) {
            _vertexCount++;
        } else if ([line hasPrefix:@"vn "]) {
            _normalsCount++;
        } else if ([line hasPrefix:@"vt "]) {
            _uvCount++;
        } else if ([line hasPrefix:@"f "]) {
            _faceCount++;
        }
    }
}

- (void) allocateBuffers
{
    _vertices = (GLfloat*)malloc(sizeof(GLfloat) * 3 * 3 * self.faceCount);
    _normals  = (GLfloat*)malloc(sizeof(GLfloat) * 3 * 3 * self.faceCount);
    _uvs      = (GLfloat*)malloc(sizeof(GLfloat) * 2 * 3 * self.faceCount);
}

- (void) dealloc
{
    if (!_vertices) free(_vertices);
    if (!_uvs)      free(_uvs);
    if (!_normals)  free(_normals);
}

@end
