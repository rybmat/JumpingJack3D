//
//  JJGLView.mm
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#define _case(key,function) case (key): \
                                  function; \
                                  break;

#define _case_flag(key,function,flag) case (key): \
                                            function; \
                                            flag = YES; \
                                            break;

#define ESCAPE 27
#define SPACE 32
#define TAB 9

#import "JJGLView.h"
#import "assets/cube.h"
#import "assets/teapot.h"

@implementation JJGLView

NSTimer *renderTimer;
JJAssetManager *assetManager;
JJObjectManager *objManager;
JJCamera *camera;

JJCharacter* character;
NSMutableSet* keyPressed;

BOOL mousePressed;

double previousTime;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mousePressed = NO;
        previousTime = CACurrentMediaTime();
    }
    
    return self;
}

- (void) prepareOpenGL
{
    [super prepareOpenGL];
    [self initOpenGL];
}

-(void) initOpenGL
{
	
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_DEPTH_TEST);
    
    [JJLight setFirstLightX: 50.0f Y: 100.0f Z: 50.0f];
    [JJLight setSecondLightX: -10.0f Y: 20.0f Z: -10.0f];
    
    assetManager = [[JJAssetManager alloc] init];
    [assetManager load];
    
    camera = [[JJCamera alloc] initWithParameters:1.0f farClipping:100.0f FoV:90.0f aspectRatio:1.0f cameraRadius:10.0f];
    
    character = [[JJCharacter alloc] initWithShaderProgram: [assetManager getShaderProgram:@"character"]
                                                    Camera: camera
                                                  Vertices: [assetManager getVertices:@"ball"]
                                                   Normals: [assetManager getNormals:@"ball"]
                                               VertexCount: [assetManager getVertexCount:@"ball"]
                                                 PositionX: 0.0f Y: 0.0f Z: 0.0f
                                                   Texture: [assetManager getTexture:@"ball"]
                                                 TexCoords: [assetManager getUvs:@"ball"]
                                                 frameRate: 60];
    [character scaleX:.5f Y:.5f Z:.5f];
    objManager = [[JJObjectManager alloc] initWithRefs:assetManager cameraRef:camera characterRef:character];
    
    [camera setWithCharacterPosition:[character position]];
    
    [objManager generateWorld];
}

- (void) dealloc
{
    
}

- (void) awakeFromNib
{
    
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

- (void) timerFired: (id)sender
{
    [self processKeys];
    [self nextFrame];
    [self display];
}

- (void) nextFrame
{
    [objManager applyAction];
    if (mousePressed == NO) {
        [camera setWithCharacterPosition:[character position] andCharactersFaceVector: character.getFaceVector];
    } else {
        [camera setWithCharacterPosition:[character position]];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    double frameTime = CACurrentMediaTime() - previousTime;
    previousTime = CACurrentMediaTime();
    [JJHUD updateFPS: 1 / (float)frameTime];
    
    glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Drawing code here.
    [objManager renderObjects];
    
    glFlush();
}

- (BOOL)canBecomeKeyView
{
    return  YES;
}

- (BOOL)acceptsFirstResponder
{
    return  YES;
}

- (void) processKeys
{
    BOOL clickedWorS = NO, clickedAorD = NO;
    if (!(keyPressed == nil) and !([keyPressed count] == 0)) {
        for (NSNumber* keyHit in keyPressed) {
            switch ([keyHit unsignedIntValue]) {
                    _case_flag('w',   [character moveForwards], clickedWorS)
                    _case_flag('s',   [character moveBackwards], clickedWorS)
                    _case_flag('a',   [character strafeLeft], clickedAorD)
                    _case_flag('d',   [character strafeRight], clickedAorD)
                    
                    _case('u', [JJHUD toggleFPSCounter])
                    
                    _case(SPACE, [character jump])
                    _case('z',   [character dive])
                    _case('q',   [character rotateLeft])
                    _case('e',   [character rotateRight])
                    _case(ESCAPE,[character portToCheckPoint])
                    _case('x',   [character changeFrameRate:180])
                    _case('c',   [character changeFrameRate:60])
                    _case('t',   [character triggerExplosion])
                default:
                    NSLog(@"%u", [keyHit unsignedIntValue]);
                    break;
            }
        }
    }
    character.deccelerateForward = !clickedWorS;
    character.deccelerateStrafe  = !clickedAorD;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    [camera zoomIn:[theEvent deltaY]/3];
}
- (void) mouseDown:(NSEvent *)theEvent
{
    mousePressed = YES;
}

- (void) mouseUp:(NSEvent *)theEvent
{
    mousePressed = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [camera rotateHorizontal:-[theEvent deltaX]/10];
    [camera rotateVertical:[theEvent deltaY]/10];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [character rotateBy:-[theEvent deltaX]/3];
}

- (void) keyUp:(NSEvent*)theEvent
{
    if (keyPressed == nil) {
        keyPressed = [[NSMutableSet alloc] init];
    }
    NSNumber* keyReleased = [NSNumber numberWithUnsignedInt:[[theEvent characters] characterAtIndex:0]];
    [keyPressed removeObject:keyReleased];
}

- (void) keyDown:(NSEvent*)theEvent
{
    if ([[theEvent characters] characterAtIndex:0] == TAB) {
        [JJHUD toggleFPSCounter];
    }
    
    if (keyPressed == nil) {
        keyPressed = [[NSMutableSet alloc] init];
    }
    NSNumber* keyHit = [NSNumber numberWithUnsignedInt:[[theEvent characters] characterAtIndex:0]];
    [keyPressed addObject:keyHit];
    
}
@end