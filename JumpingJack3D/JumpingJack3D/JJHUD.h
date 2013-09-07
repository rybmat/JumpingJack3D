//
//  JJHUD.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 9/3/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJHUD: NSView

+ (void) changeScore:(int)aScore andLives:(int)lives;

+ (void) changeMessage:(NSTimer*)timer;
+ (void) flashMessage:(NSString*)message for:(float)seconds;
@end
