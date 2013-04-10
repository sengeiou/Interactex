//
//  THTimerPaletteItem.m
//  TangoHapps
//
//  Created by Juan Haladjian on 2/21/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THTimerPaletteItem.h"
#import "THCustomProject.h"
#import "THTimerEditable.h"

@implementation THTimerPaletteItem

- (BOOL)canBeDroppedAt:(CGPoint)location {
    return YES;
}

- (void)dropAt:(CGPoint)location {
    THTimerEditable * timer = [[THTimerEditable alloc] init];
    timer.position = location;
        
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    [project addTrigger:timer];
}

@end
