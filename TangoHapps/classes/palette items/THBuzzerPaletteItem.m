//
//  THBuzzerPaletteItem.m
//  TangoHapps
//
//  Created by Juan Haladjian on 9/15/12.
//  Copyright (c) 2012 TUM. All rights reserved.
//

#import "THBuzzerPaletteItem.h"
#import "THBuzzerEditableObject.h"

@implementation THBuzzerPaletteItem

- (void)dropAt:(CGPoint)location {
    THBuzzerEditableObject * buzzer = [[THBuzzerEditableObject alloc] init];
    buzzer.position = location;
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    [project addClotheObject:buzzer];
}

@end
