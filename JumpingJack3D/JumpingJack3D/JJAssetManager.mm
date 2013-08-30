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
const NSString* DDStextureExtension = @"dds";
const NSString* JPGtextureExtension = @"jpg";

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
                                                           TGAtextureExtension, PNGtextureExtension, wavefrontObjectExtension,
                                                           DDStextureExtension, JPGtextureExtension, nil];
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
        NSLog(@"%@", key);
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
    NSArray* filePathsPNG = [self.mainBundle pathsForResourcesOfType:self.extensions[JPG] inDirectory:@""];
    
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

- (BOOL) loadTexture:(NSString *)fileName withColorMode:(GLuint)cmode texHandler:(GLuint *)tex
{
    NSString* extension = [[fileName pathExtension] lowercaseString];
    
    if ([extension isEqualToString: @"dds"]) {
        [self loadTextureDDS:fileName texHandler:tex];
    } else {
        [self loadTextureOtherThanDDS:fileName withColorMode:cmode texHandler:tex];
    }
    return YES;
}

- (BOOL) loadTextureOtherThanDDS: (NSString*)fileName withColorMode: (GLuint)cmode texHandler: (GLuint*)tex
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

- (BOOL) loadTextureDDS: (NSString*)fileName texHandler:(GLuint*)textureID
{
    const char* imagepath = [fileName cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char header[124];
    
    FILE *fp;
    
    /* try to open the file */
    fp = fopen(imagepath, "rb");
    if (fp == NULL)
        return 0;
    
    /* verify the type of file */
    char filecode[4];
    fread(filecode, 1, 4, fp);
    if (strncmp(filecode, "DDS ", 4) != 0) {
        fclose(fp);
        return 0;
    }
    
    /* get the surface desc */
    fread(&header, 124, 1, fp);
    
    unsigned int height      = *(unsigned int*)&(header[8 ]);
    unsigned int width           = *(unsigned int*)&(header[12]);
    unsigned int linearSize  = *(unsigned int*)&(header[16]);
    unsigned int mipMapCount = *(unsigned int*)&(header[24]);
    unsigned int fourCC      = *(unsigned int*)&(header[80]);
    
    
    unsigned char * buffer;
    unsigned int bufsize;
    /* how big is it going to be including all mipmaps? */
    bufsize = mipMapCount > 1 ? linearSize * 2 : linearSize;
    buffer = (unsigned char*)malloc(bufsize * sizeof(unsigned char));
    fread(buffer, 1, bufsize, fp);
    /* close the file pointer */
    fclose(fp);
    
    unsigned int components  = (fourCC == FOURCC_DXT1) ? 3 : 4;
    unsigned int format;
    switch(fourCC)
    {
        case FOURCC_DXT1:
            format = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
            break;
        case FOURCC_DXT3:
            format = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
            break;
        case FOURCC_DXT5:
            format = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
            break;
        default:
            free(buffer);
            return 0;
    }
    
    glGenTextures(1, textureID);
    
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, *textureID);
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    
    unsigned int blockSize = (format == GL_COMPRESSED_RGBA_S3TC_DXT1_EXT) ? 8 : 16;
    unsigned int offset = 0;
    
    /* load the mipmaps */
    for (unsigned int level = 0; level < mipMapCount && (width || height); ++level)
    {
        unsigned int size = ((width+3)/4)*((height+3)/4)*blockSize;
        glCompressedTexImage2D(GL_TEXTURE_2D, level, format, width, height,
                               0, size, buffer + offset);
        
        offset += size;
        width  /= 2;
        height /= 2;
    }
    
    free(buffer);
    return YES;
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

- (GLuint) getTexture: (NSString*) dictionaryKey{
    tex = [[self textures][dictionaryKey] unsignedIntValue];
    return tex;
}
@end
