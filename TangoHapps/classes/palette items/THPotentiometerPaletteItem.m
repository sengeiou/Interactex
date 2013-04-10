//
//  THPotentiometerPaletteItem.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/8/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THPotentiometerPaletteItem.h"
#import "THPotentiometerEditableObject.h"

@implementation THPotentiometerPaletteItem


- (void)dropAt:(CGPoint)location {
    THPotentiometerEditableObject * potentiometer = [[THPotentiometerEditableObject alloc] init];
    potentiometer.position = location;
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    [project addClotheObject:potentiometer];
}

@end
