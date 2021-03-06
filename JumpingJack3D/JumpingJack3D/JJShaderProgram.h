//
//  JJShaderProgram.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 08.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import <string.h>

@interface JJShaderProgram : NSObject

@property GLuint shaderProgram;
@property GLuint vShader;
@property GLuint gShader;
@property GLuint fShader;

-(id) initWithVertexFile: (NSString*) vShaderFile GeometryShaderFile: (NSString*) gShaderFile FragmentShaderFile: (NSString*) fShaderFile;
-(void) use;
-(GLuint) getUniformLocation: (NSString*) variableName;
-(GLuint) getAttribLocation: (NSString*) variableName;

@end