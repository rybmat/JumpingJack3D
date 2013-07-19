//
//  JJGLView.mm
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJGLView.h"

@implementation JJGLView

NSTimer *renderTimer;
JJAssetManager *assetManager;


//to delete
JJStaticPlatform *platform;

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
    
    assetManager = [[JJAssetManager alloc] init];
    [assetManager load];
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
    
    
    renderTimer = [NSTimer timerWithTimeInterval:0.001
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
            
            return;
        }
        if ( keyChar == NSRightArrowFunctionKey ) {
         
            return;
        }
        if ( keyChar == NSUpArrowFunctionKey ) {
           
            return;
        }
        if ( keyChar == NSDownArrowFunctionKey ) {
            
            return;
        }
        if ( keyChar == ' '){
            
        }
        
        
        //[super keyDown:theEvent];
    }
    //[super keyDown:theEvent];
    
}

@end
