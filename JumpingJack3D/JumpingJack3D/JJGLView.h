//
//  JJGLView.h
//  JumpingJack3D
//
//  Created by Mateusz Rybarski on 10.07.2013.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>

#import "glm/glm.hpp"
#import "glm/gtc/matrix_transform.hpp"
#import "glm/gtc/type_ptr.hpp"

#import "JJAssetManager.h"
#import "JJStaticPlatform.h"
#import "JJCamera.h"
#import "JJLight.h"


@interface JJGLView : NSOpenGLView

@end
