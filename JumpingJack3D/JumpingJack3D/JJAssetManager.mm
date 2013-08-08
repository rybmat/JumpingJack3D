//
//  JJAssetManager.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 7/10/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJAssetManager.h"
#import "JJAssetManagerPrivate.h"

@implementation JJAssetManager

const NSString* vertexShaderExtension = @"vsh";
const NSString* geometryShaderExtension = @"gsh";
const NSString* fragmentShaderExtension = @"fsh";
const NSString* TGAtextureExtension= @"tga";
const NSString* PNGtextureExtension = @"png";
const NSString* wavefrontObjectExtension = @"obj";

GLuint tex;

- (id) init
{
    self = [super init];
    if (self) {
        _textures   = [[NSDictionary alloc] init];
        _meshes     = [[NSDictionary alloc] init];
        _shaders    = [[NSDictionary alloc] init];
        self.mainBundle = [NSBundle mainBundle];
        self.extensions = [[NSArray alloc] initWithObjects:vertexShaderExtension, geometryShaderExtension, fragmentShaderExtension,
                                                           TGAtextureExtension, PNGtextureExtension, wavefrontObjectExtension, nil];
    }
    return self;
}

- (void) load
{
    [self loadShaders];
    NSLog(@"AssetManager: Shaders loaded");
    [self loadTextures];
    NSLog(@"AssetManager: Textures loaded");
    [self loadMeshes];
    NSLog(@"AssetManager: Meshes loaded");
}


- (void) loadShaders
{
    NSDictionary* vertexShaderFiles = [self createShaderDirsDictionary:VERTEX_SHADER];
    NSDictionary* geometryShaderFiles = [self createShaderDirsDictionary:GEOMETRY_SHADER];
    NSDictionary* fragmentShaderFiles = [self createShaderDirsDictionary:FRAGMENT_SHADER];
    
    NSMutableDictionary* shaderPrograms = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in [vertexShaderFiles allKeys]) {
        JJShaderProgram* program = [[JJShaderProgram alloc] initWithVertexFile:vertexShaderFiles[key]
                                                            GeometryShaderFile:geometryShaderFiles[key]
                                                            FragmentShaderFile:fragmentShaderFiles[key]];
        [shaderPrograms setObject:program forKey:key];
    }
    _shaders = shaderPrograms;
}

- (void) loadMeshes
{
    NSArray* filePathsObj = [self.mainBundle pathsForResourcesOfType:self.extensions[OBJ] inDirectory:@""];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    for (NSString* filePath in filePathsObj) {
        JJMesh* mesh = [[JJMesh alloc] init];
        NSString* filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
        
        if ([mesh loadModel:filePath] == NO) {
            NSLog(@"AssetManager: model %@ not loaded", [filePath lastPathComponent]);
        } else {
            [dict setObject:mesh forKey:filename];
        }
    }
    
    _meshes = dict;
}

- (void) loadTextures
{
    NSArray* filePathsTGA = [self.mainBundle pathsForResourcesOfType:self.extensions[TGA] inDirectory:@""];
    NSArray* filePathsPNG = [self.mainBundle pathsForResourcesOfType:self.extensions[PNG] inDirectory:@""];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
for (NSString* filePath in filePathsTGA) {
        GLuint textureHandler;
        NSString* filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
        
        if ([self loadTexture:filePath withColorMode:GL_RGB texHandler:&textureHandler] == NO) {
            NSLog(@"AssetManager: texture %@ not loaded", [filePath lastPathComponent]);
        } else {
            
            [dict setObject:[NSNumber numberWithUnsignedInt:textureHandler] forKey:filename];
        }
    }

    for (NSString* filePath in filePathsPNG) {
        GLuint textureHandler;
        NSString* filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
        
        if ([self loadTexture:filePath withColorMode:GL_RGB texHandler:&textureHandler] == NO) {
            NSLog(@"AssetManager: texture %@ not loaded", [filePath lastPathComponent]);
        } else {
            [dict setObject:[NSNumber numberWithUnsignedInt:textureHandler] forKey:filename];
        }
    }
    _textures = dict;
}

- (BOOL) loadTexture: (NSString*)fileName withColorMode: (GLuint)cmode texHandler: (GLuint*)tex
{
    
    NSImage * img =  [[NSImage alloc] initWithContentsOfFile: fileName];
    if(img == nil){
        NSLog(@"AssetManager: loadTexture: file not found");
        return FALSE;
    }
    else if(img.size.height == 0 || img.size.width == 0){
        NSLog(@"AssetManager: loadTexture: file size is zero");
        return FALSE;
    }
    NSBitmapImageRep *rep = nil;
    rep = [[NSBitmapImageRep alloc] initWithData: [img TIFFRepresentation]];
    if(rep == nil){
        NSLog(@"%@",rep);
        return FALSE;
    }
    
    glGenTextures( 1, tex);
    glBindTexture( GL_TEXTURE_2D, *tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexImage2D( GL_TEXTURE_2D, 0, cmode, rep.size.width,
                 rep.size.height, 0, cmode,
                 GL_UNSIGNED_BYTE, rep.bitmapData);
    
    return TRUE;
}

- (NSDictionary*) createShaderDirsDictionary:(extensionType)aType
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSArray* filePaths = [self.mainBundle pathsForResourcesOfType:self.extensions[aType] inDirectory:@""];
    for (NSString* filePath in filePaths) {
        NSString* key = [[filePath lastPathComponent] stringByDeletingPathExtension];
        [dict setObject:filePath forKey:key];
    }
    return dict;
}

- (JJShaderProgram*) getShaderProgram: (NSString*) dictionaryKey
{
    return [self shaders][dictionaryKey];
}

- (float*) getVertices: (NSString*) dictionaryKey{
    return [[self meshes][dictionaryKey] vertices];
}

- (float*) getNormals: (NSString*) dictionaryKey{
    return [[self meshes][dictionaryKey] normals];
}

- (float*) getUvs: (NSString*) dictionaryKey{
    return [[self meshes][dictionaryKey] uvs];
}

- (int) getVertexCount: (NSString*) dictionaryKey{
    return [[self meshes][dictionaryKey] uncompressedVertexCount];
}

- (GLuint*) getTexture: (NSString*) dictionaryKey{
    tex = [[self textures][dictionaryKey] unsignedIntValue];
    return &tex;
}
@end
