//
//  AppDelegate.m
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setAcceptsMouseMovedEvents:YES];
 
    [NSCursor hide];
    
    NSRect newSize = [[NSScreen mainScreen] frame];
    [self.window setFrame:newSize display:YES animate:YES];
}


@end