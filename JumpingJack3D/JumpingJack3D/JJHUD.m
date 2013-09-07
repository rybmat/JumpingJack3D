//
//  JJHUD.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 9/3/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJHUD.h"

@implementation JJHUD

static NSTextField* scoreAndLives;
static NSTextField* centeredMessage;

NSRect screenSize;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        screenSize = [[NSScreen mainScreen] frame];

        NSFont* font;
        
        font = [NSFont fontWithName:@"Helvetica" size:50];
        
        scoreAndLives  = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 10, 500, 120)];
        [scoreAndLives setStringValue:@"Score: "];
        [scoreAndLives setBezeled:NO];
        [scoreAndLives setDrawsBackground:NO];
        [scoreAndLives setEditable:NO];
        [scoreAndLives setSelectable:NO];
        [scoreAndLives setTextColor:[NSColor colorWithCalibratedRed:0 green:1 blue:0.8f alpha:1]];
        [scoreAndLives setFont:font];
        [self addSubview:scoreAndLives positioned:-1 relativeTo:self];
        
        centeredMessage  = [[NSTextField alloc] initWithFrame:NSMakeRect(screenSize.size.width/2 - 250, screenSize.size.height/2 - 50, 500, 100)];
        [centeredMessage setStringValue:@""];
        [centeredMessage setBezeled:NO];
        [centeredMessage setDrawsBackground:NO];
        [centeredMessage setEditable:NO];
        [centeredMessage setSelectable:NO];
        [centeredMessage setTextColor:[NSColor colorWithCalibratedRed:0 green:1 blue:0.8f alpha:1]];
        [centeredMessage setFont:font];
        [self addSubview:centeredMessage positioned:-1 relativeTo:self];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
        
}

+ (void) changeScore:(int)aScore andLives:(int)lives;
{
    [scoreAndLives setStringValue:[NSString stringWithFormat:@"Score: %d\nLives:  %d", aScore, lives]];
}

+ (void) changeMessage:(NSTimer *)timer;
{
    [centeredMessage setStringValue:(NSString*)[timer userInfo]];
}

+ (void) flashMessage:(NSString*)message for:(float)seconds;
{
    [centeredMessage setStringValue:message];
    
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(changeMessage:) userInfo:@"" repeats:NO];
}

@end
