 //
//  ShaderProgram.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 08.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJShaderProgram.h"

@implementation JJShaderProgram




- (const GLchar*) readFile: (NSString*) fileName{
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:fileName] == NO){
        NSLog(@"ShaderLoader: file %@ does not exists", [fileName lastPathComponent]);
        return nil;
    }
    
    
    NSString* content = [[NSString alloc] initWithData:[fm contentsAtPath:fileName] encoding:NSUTF8StringEncoding];
    const char* c = [content UTF8String];
    const char* c2 = strdup(c); //string jest kopiowany gdyż wartość zwrócona przez UTF8String jest zbyt wcześnie zwalniana
    return c2;
}

- (GLuint) loadShaderWithType: (GLenum) shaderType andFileName: (NSString*) fileName{
    //uchwyt na shader
	GLuint shader=glCreateShader(shaderType);   //GL_VERTEX_SHADER, GL_GEOMETRY_SHADER lub GL_FRAGMENT_SHADER
	NSLog(@"\t\t Handle generated");
    
    //Wczytanie pliku z shaderem
	const GLchar* shaderSource= [self readFile:fileName];
	NSLog(@"\t\t File loaded");
    
    //Powiązanie shadera z uchwytem
	glShaderSource(shader,1,&shaderSource,NULL);
	NSLog(@"\t\t Source linked to handle");
    
    //kompilacja źródła
	glCompileShader(shader);
    NSLog(@"\t\t Source compiled");
    
	//usunięcie źródła shadera z pamięci
	delete[] shaderSource;
    
    //log błędów kompilacji
	int infologLength = 0;
	int charsWritten  = 0;
	char *infoLog;
    
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH,&infologLength);
    
	if (infologLength > 1) {
		infoLog = new char[infologLength];
		glGetShaderInfoLog(shader, infologLength, &charsWritten, infoLog);
		printf("%s\n",infoLog);
		delete []infoLog;
	}
    
    
	return shader;
}


-(id) initWithVertexFile: (NSString*) vShaderFile GeometryShaderFile: (NSString*) gShaderFile FragmentShaderFile: (NSString*) fShaderFile {
    
    self = [super init];
    NSLog(@"ShaderLoader: Creating shader program for <%@>", [[fShaderFile lastPathComponent] stringByDeletingPathExtension]);
    NSLog(@"\t Loading vertex shader %@...", [vShaderFile lastPathComponent]);
	_vShader= [self loadShaderWithType:GL_VERTEX_SHADER andFileName:vShaderFile];
    
    if (gShaderFile!=NULL) {
		NSLog(@"\t Loading geometry shader %@...", [gShaderFile lastPathComponent]);
		_gShader = [self loadShaderWithType:GL_GEOMETRY_SHADER andFileName: gShaderFile];
	} else {
		_gShader=0;
	}
    
    NSLog(@"\t Loading fragment shader %@...", [fShaderFile lastPathComponent]);
	_fShader= [self loadShaderWithType: GL_FRAGMENT_SHADER andFileName: fShaderFile];
    
	_shaderProgram=glCreateProgram();
    
    //NSLog(@"prog %u vs %u, fs %u",shaderProgram, vShader, fShader);
    
    glAttachShader(_shaderProgram,_vShader);
	glAttachShader(_shaderProgram,_fShader);
	if (gShaderFile!=NULL){
        glAttachShader(_shaderProgram,_gShader);
    }
	glLinkProgram(_shaderProgram);
    
    
    //log błędów linkowania
    int infologLength = 0;
	int charsWritten  = 0;
	char *infoLog;
    
	glGetProgramiv(_shaderProgram, GL_INFO_LOG_LENGTH,&infologLength);
    
	if (infologLength > 1)
	{
		infoLog = new char[infologLength];
		glGetProgramInfoLog(_shaderProgram, infologLength, &charsWritten, infoLog);
		NSLog(@"%s",infoLog);
		delete []infoLog;
	}
    
	NSLog(@"ShaderLoader: Program successfully created!");
    return self;
}

-(void) use {
	glUseProgram(_shaderProgram);
}

//Zwraca numer slotu zmiennej jednorodnej o nazwie variableName
-(GLuint) getUniformLocation:(char*) variableName {
	return glGetUniformLocation(_shaderProgram,variableName);
}

//Zwraca numer slotu atrybutu o nazwie variableName
-(GLuint) getAttribLocation:(char*) variableName {
	return glGetAttribLocation(_shaderProgram,variableName);
}

-(void) dealloc{
	glDetachShader(_shaderProgram, _vShader);
	if (_gShader!=0)
        glDetachShader(_shaderProgram, _gShader);
	glDetachShader(_shaderProgram, _fShader);
    
	glDeleteShader(_vShader);
	if (_gShader!=0)
        glDeleteShader(_gShader);
	glDeleteShader(_fShader);
    
	glDeleteProgram(_shaderProgram);
}

@end