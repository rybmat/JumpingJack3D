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
JJObjectManager *objManager;
JJCamera *camera;

NSPoint startingPoint;

JJCharacter* character;

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
    
    [JJLight setFirstLightX: 10.0f Y: 10000.0f Z: -5.0f];
    [JJLight setSecondLightX: -10.0f Y: -1.0f Z: -5.0f];
    
    assetManager = [[JJAssetManager alloc] init];
    [assetManager load];
    
    camera = [[JJCamera alloc] initWithParameters:1.0f farClipping:50.0f FoV:50.0f aspectRatio:1.0f cameraRadius:10.0f];
    
    character = [[JJCharacter alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                                 Camera: camera
                                                               Vertices: [assetManager getVertices:@"cube"]
                                                                Normals: [assetManager getNormals:@"cube"]
                                                            VertexCount: [assetManager getVertexCount:@"cube"]
                                                              PositionX: -5.0f Y:2.0f Z:3.0f
                                                                Texture: [assetManager getTexture:@"platform"]
                                                              TexCoords: [assetManager getUvs:@"cube"]];
    [objManager addObject:character];
    
    objManager = [[JJObjectManager alloc] initWithRefs:assetManager cameraRef:camera characterRef:character];

    [camera setWithCharacterPosition:[character getModelPosition]];

    /*
    JJDynamicPlatform* dynPlatform = [[JJDynamicPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                            Camera: camera
                                                          Vertices: [assetManager getVertices:@"cube"]
                                                           Normals: [assetManager getNormals:@"cube"]
                                                       VertexCount: [assetManager getVertexCount:@"cube"]
                                                         PositionX: 1.0f Y: 0.0f Z: 0.0f
                                                        PathPointB: glm::vec4(2.0f,3.0f,4.0f,1.0f)
                                                          StepSize: 0.05f
                                                           Texture: [assetManager getTexture:@"cube"]
                                                     TextureCoords: [assetManager getUvs:@"cube"]];
    
    [objManager addObject:dynPlatform];
    
    JJDynamicPlatform* dynPlatform2 = [[JJDynamicPlatform alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                            Camera: camera
                                                          Vertices: cubeVertices
                                                           Normals: cubeNormals
                                                       VertexCount: cubeVertexCount
                                                         PositionX: -1.0f Y: 0.0f Z: 0.0f
                                                        PathPointB: glm::vec4(-2.0f,-3.0f,-4.0f,1.0f)
                                                          StepSize: 0.05f
                                                           Texture: [assetManager getTexture:@"platform"]
                                                     TextureCoords: cubeTexCoords];
    [objManager addObject:dynPlatform2];

     */
    
    [objManager generateWorld];
    




    
   // NSLog(@"%d", [character vertexCount]);
  //wypisanie normalnych/wierzcholkow
   /* for( int i = 0; i < 12 * 3 * 4; i++){
        printf("%f, ",[character normals][i]);
        if(i % 4 == 3){
            printf("\n");
        }
    }
*/
    //wypisanie UV-ek
    /*for(int j = 0; j < 36 * 2; j++){
        printf("%f, ", [assetManager getUvs:@"cube"][j]);
        if(j % 2 == 1){
            printf("\n");
        }
    }*/
    
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
    [objManager applyAction];
    [camera setWithCharacterPosition:[character getModelPosition]];// andCharactersFaceVector:glm::vec3(1,1,1)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Drawing code here.
    [objManager renderObjects];

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
            //[character rotateY:1.0f byAngle:5];
            [camera rotateHorizontal:7.0f];
            return;
        }
        if ( keyChar == NSRightArrowFunctionKey ) {
            //[character rotateY:-1.0f byAngle:5];
            [camera rotateHorizontal:-7.0f];
            return;
        }
        if ( keyChar == NSUpArrowFunctionKey ) {
            //[character moveZ:0.1f];
            [camera rotateVertical:7.0f];
            return;
        }
        if ( keyChar == NSDownArrowFunctionKey ) {
            //[character moveZ:-0.1f];
            [camera rotateVertical:-7.0f];
            return;
        }
        if ( keyChar == 'w'){
            [character moveZ:0.1f];
            return;
        }
        if ( keyChar == 's'){
            [character moveZ:-0.1f];
            return;
        }
        if ( keyChar == 'a'){
            [character rotateY:1.0f byAngle:5];
            return;
        }
        if ( keyChar == 'd'){
            [character rotateY:-1.0f byAngle:5];
            return;
        }
        
        //[super keyDown:theEvent];
    }
    //[super keyDown:theEvent];

}

- (void)scrollWheel:(NSEvent *)theEvent {
    [camera zoomIn:[theEvent deltaY]];
    NSLog(@"user scrolled %f horizontally and %f vertically", [theEvent deltaX], [theEvent deltaY]);
}

- (void) mouseDown:(NSEvent *)theEvent {
    startingPoint = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint endPoint = [theEvent locationInWindow];
    [camera rotateHorizontal:-(endPoint.x - startingPoint.x)/100];
    [camera rotateVertical:-(endPoint.y - startingPoint.y)/100];
}

@end
