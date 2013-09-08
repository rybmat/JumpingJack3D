//
//  JJGLView.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CABase.h>

#import "glm/glm.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"

#import "JJFPSCounter.h"
#import "JJAssetManager.h"
#import "JJObjectManager.h"
#import "JJStaticPlatform.h"
#import "JJDynamicPlatform.h"
#import "JJCharacter.h"
#import "JJCamera.h"
#import "JJLight.h"


@interface JJGLView : NSOpenGLView

@end
