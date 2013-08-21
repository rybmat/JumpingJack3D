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
BOOL mousePressed;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mousePressed = NO;
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
    
    [objManager generateWorld];
    
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
    if (mousePressed == NO) {
        [camera setWithCharacterPosition:[character getModelPosition] andCharactersFaceVector: [character getFaceVectorInWorldSpace]];
    } else {
        [camera setWithCharacterPosition:[character getModelPosition]];
    }
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
    
    NSString *theArrow = [theEvent characters];
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
            [character moveZ:0.4f];
            return;
        }
        if ( keyChar == 's'){
            [character moveZ:-0.4f];
            return;
        }
        if ( keyChar == 'q'){
            [character rotateY:1.0f byAngle:10];
            return;
        }
        if ( keyChar == 'e'){
            [character rotateY:-1.0f byAngle:10];
            return;
        }
        if ( keyChar == 'a'){
            [character moveX:0.4f];
            return;
        }
        if ( keyChar == 'd'){
            [character moveX:-0.4f];
            return;
        }
        
        //[super keyDown:theEvent];
    }
    //[super keyDown:theEvent];

}

- (void)scrollWheel:(NSEvent *)theEvent {
    [camera zoomIn:[theEvent deltaY]/3];
    NSLog(@"user scrolled %f horizontally and %f vertically", [theEvent deltaX], [theEvent deltaY]);
}

- (void) mouseDown:(NSEvent *)theEvent {
    mousePressed = YES;
    startingPoint = [theEvent locationInWindow];
}

- (void) mouseUp:(NSEvent *)theEvent {
    mousePressed = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [camera rotateHorizontal:-[theEvent deltaX]/10];
    [camera rotateVertical:[theEvent deltaY]/10];
}

@end
