//
//  JJObjectManager.h
//  JumpingJack3D
//
//  Created by Maciej Żurad on 8/16/13.
//  Copyright (c) 2013 Mateusz Rybarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJMapGenerator.h"
#import "JJStaticPlatform.h"
#import "JJDynamicEnemy.h"
#import "JJStaticEnemy.h"
#import "JJAssetManager.h"
#import "JJCharacter.h"
#import "JJCamera.h"
#import "JJFloor.h"

@interface JJObjectManager : NSObject

- (id) initWithRefs:(JJAssetManager*)aAssetManagerRef cameraRef:(JJCamera*)aCameraRef characterRef:(JJCharacter*)aCharacterRef;
- (void) addObject:(id)aObject;

- (void) generateWorld;

- (void) renderObjects;
- (void) applyAction;

- (void) showNewBlock;

@end
