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

JJCharacter* character;
NSMutableSet* keyPressed;

BOOL mousePressed;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mousePressed = NO;
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
    
    [JJLight setFirstLightX: 10.0f Y: 10000.0f Z: -5.0f];
    [JJLight setSecondLightX: -10.0f Y: -1.0f Z: -5.0f];
    
    assetManager = [[JJAssetManager alloc] init];
    [assetManager load];
    
    camera = [[JJCamera alloc] initWithParameters:1.0f farClipping:1000.0f FoV:90.0f aspectRatio:1.0f cameraRadius:10.0f];
    
    character = [[JJCharacter alloc] initWithShaderProgram: [assetManager getShaderProgram:@"platform"]
                                                                 Camera: camera
                                                               Vertices: [assetManager getVertices:@"sphere"]
                                                                Normals: [assetManager getNormals:@"sphere"]
                                                            VertexCount: [assetManager getVertexCount:@"sphere"]
                                                              PositionX: -5.0f Y:2.0f Z:3.0f
                                                                Texture: [assetManager getTexture:@"sphere"]
                                                              TexCoords: [assetManager getUvs:@"sphere"]];
    
    objManager = [[JJObjectManager alloc] initWithRefs:assetManager cameraRef:camera characterRef:character];
    [objManager addObject:character];

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
    if (!(keyPressed == nil) and !([keyPressed count] == 0)) {
        for (NSNumber* keyHit in keyPressed) {
            switch ([keyHit unsignedIntValue]) {
                case 'w':
                    [character moveForwards];
                    break;
                case 's':
                    [character moveBackwards];
                    break;
                case 'a':
                    [character strafeLeft];
                    break;
                case 'd':
                    [character strafeRight];
                    break;
                case ' ':
                    [character jump];
                    break;
                case 'z':
                    [character dive];
                    break;
                case 'q':
                    [character rotateLeft];
                    break;
                case 'e':
                    [character rotateRight];
                    break;
                default:
                    break;
            }
        }
    }
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
    [character rotateBy:-[theEvent deltaX]/10];
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
    //NSLog(@"%f %f %f", character.getFaceVector.x, character.getFaceVector.y, character.getFaceVector.z);
    NSLog(@"%f %f %f", character.rotation.x, character.rotation.y, character.rotation.z);

    [objManager showNewBlock];
    
    if (keyPressed == nil) {
        keyPressed = [[NSMutableSet alloc] init];
    }
    NSNumber* keyHit = [NSNumber numberWithUnsignedInt:[[theEvent characters] characterAtIndex:0]];
    [keyPressed addObject:keyHit];
    
}
@end
