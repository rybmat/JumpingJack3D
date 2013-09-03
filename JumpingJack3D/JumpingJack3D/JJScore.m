//
//  JJScore.m
//  JumpingJack3D
//
//  Created by Maciej Żurad on 9/3/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "JJScore.h"

@implementation JJScore

static NSTextField* textField;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSFont* font;
        
        font = [NSFont fontWithName:@"Helvetica" size:50];
        
        textField  = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 10, 500, 120)];
        [textField setStringValue:@"Score: "];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        [textField setSelectable:NO];
        [textField setTextColor:[NSColor colorWithCalibratedRed:0 green:1 blue:0.8f alpha:1]];
        [textField setFont:font];
        [self addSubview:textField positioned:-1 relativeTo:self];

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

+ (void) changeText:(NSString *)text
{
    [textField setStringValue:text];
}
@end
