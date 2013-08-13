//
//  JJGLView.mm
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJGLView.h"
#import "cube.h"
#import "teapot.h"
@implementation JJGLView

NSTimer *renderTimer;
JJAssetManager *assetManager;
JJCamera *camera;



//to delete////
JJStaticPlatform *platform;
JJDynamicPlatform *dynPlatform, *dynPlatform2;
JJStaticPlatform *cube;

JJCharacter *character;

//////////////////////////

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) prepareOpenGL{
    [super prepareOpenGL];
    [self initOpenGL];
}

-(void) initOpenGL {
	
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_DEPTH_TEST);
    
    [JJLight setFirstLightX: 5.0f Y: 0.0f Z: -100.0f];
    [JJLight setSecondLightX: -5.0f Y: 0.0f Z: -100.0f];
    
    assetManager = [[JJAssetManager alloc] init];
    [assetManager load];
    camera = [[JJCamera alloc] init];
    
    /*cube = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                        Camera: camera
                                                      Vertices: [assetManager getVertices:@"cube"]
                                                       Normals: [assetManager getNormals:@"cube"]
                                                   VertexCount: [assetManager getVertexCount:@"cube"]
                                                     PositionX: 1.0f Y: 0.0f Z: 0.0f
                                                       Texture: [assetManager getTexture: @"cube"]
                                                     TexCoords: [assetManager getUvs:@"cube"]];//cubeTexCoords];*/
    
    /*platform = [[JJStaticPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                        Camera: camera
                                                      Vertices: teapotVertices
                                                       Normals: teapotNormals
                                                   VertexCount: teapotVertexCount
                                                     PositionX: 1.0f Y: 0.0f Z: 0.0f
                                                       Texture: [assetManager getTexture: @"metal"]
                                                     TexCoords: teapotTexCoords];//cubeTexCoords];
    
    [platform rotateX:1.0f Y:3.0f Z:0.0f ByAngle: -40.0f];
    
    glm::vec4 pos = [platform getModelPosition];
    NSLog(@"platform position: x: %f, y: %f, z: %f, w: %f", pos.x, pos.y, pos.z, pos.w);
    */
    
    dynPlatform = [[JJDynamicPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                            Camera: camera
                                                          Vertices: [assetManager getVertices:@"cube"]
                                                           Normals: [assetManager getNormals:@"cube"]
                                                       VertexCount: [assetManager getVertexCount:@"cube"]
                                                         PositionX: 1.0f Y: 0.0f Z: 0.0f
                                                        PathPointB: glm::vec4(2.0f,3.0f,4.0f,1.0f)
                                          TimeIntervalBetweenMoves: 0.03f
                                                           Texture: [assetManager getTexture:@"cube"]
                                                     TextureCoords: [assetManager getUvs:@"cube"]];
    /*
    dynPlatform2 = [[JJDynamicPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                            Camera: camera
                                                          Vertices: cubeVertices
                                                           Normals: cubeNormals
                                                       VertexCount: cubeVertexCount
                                                         PositionX: -1.0f Y: 0.0f Z: 0.0f
                                                        PathPointB: glm::vec4(-2.0f,-3.0f,-4.0f,1.0f)
                                          TimeIntervalBetweenMoves: 0.03f
                                                           Texture: [assetManager getTexture:@"platform"]
                                                     TextureCoords: cubeTexCoords];
    */
    character = [[JJCharacter alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                    Camera: camera
                                                  Vertices: [assetManager getVertices:@"cube"]
                                                   Normals: [assetManager getNormals:@"cube"]
                                               VertexCount: [assetManager getVertexCount:@"cube"]
                                                 PositionX: 1.0f Y:-2.0f Z:0.0f
                                                   Texture: [assetManager getTexture:@"cube"]
                                                 TexCoords: [assetManager getUvs:@"cube"]];
    
    
    
    NSLog(@"%d", [character vertexCount]);

    
}

- (void) dealloc{
 
}

- (void) awakeFromNib{
    
    NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
        
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
        
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
    
    [self setPixelFormat:pf];
    
    [self setOpenGLContext:context];
    
    
    renderTimer = [NSTimer timerWithTimeInterval:1/60.0
                                          target:self
                                        selector:@selector(timerFired:)
                                        userInfo:nil
                                         repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer
                                 forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop]
     addTimer:renderTimer
     forMode:NSEventTrackingRunLoopMode];
}

- (void) timerFired: (id)sender{
    
    [self nextFrame];
    [self display];
}

- (void) nextFrame{
    
    //calculateing new positions here
    
    // np nowe pozycje poruszających sie klocków
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Drawing code here.
    [platform render];
    [dynPlatform render];
    [dynPlatform2 render];
    [character render];
    glFlush();
}

- (BOOL)canBecomeKeyView {
    return  YES;
}
- (BOOL)acceptsFirstResponder {
    return  YES;
}

- (void) keyDown:(NSEvent *)theEvent{
    
    NSString *theArrow = [theEvent charactersIgnoringModifiers];
    unichar keyChar = 0;
    if ( [theArrow length] == 0 )
        return;
    if ( [theArrow length] == 1 ) {
        keyChar = [theArrow characterAtIndex:0];
        if ( keyChar == NSLeftArrowFunctionKey ) {
            [character rotateY:1.0f byAngle:5];
            return;
        }
        if ( keyChar == NSRightArrowFunctionKey ) {
            [character rotateY:-1.0f byAngle:5];
            return;
        }
        if ( keyChar == NSUpArrowFunctionKey ) {
           [character moveZ:0.1f];
            return;
        }
        if ( keyChar == NSDownArrowFunctionKey ) {
            [character moveZ:-0.1f];
            return;
        }
        if ( keyChar == ' '){
            
        }
        
        
        //[super keyDown:theEvent];
    }
    //[super keyDown:theEvent];
    
}

@end
