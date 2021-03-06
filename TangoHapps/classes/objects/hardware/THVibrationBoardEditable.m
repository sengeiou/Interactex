/*
THVibrationBoardEditable.m
Interactex Designer

Created by Juan Haladjian on 05/10/2013.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "THVibrationBoardEditable.h"
#import "THVibrationBoard.h"
#import "THVibrationBoardProperties.h"
#import "THElementPinEditable.h"
#import "THElementPin.h"

@implementation THVibrationBoardEditable

@dynamic on;
@dynamic onAtStart;
@dynamic frequency;

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THVibrationBoard alloc] init];
        
        [self loadVibrationBoard];
        [super loadPins];
    }
    return self;
}

-(void) loadVibrationBoard{
    
    self.type = kHardwareTypeVibeBoard;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if(self){
        [self loadVibrationBoard];
        
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*) coder {
    [super encodeWithCoder:coder];
    
}

-(id)copyWithZone:(NSZone*) zone {
    THVibrationBoardEditable * copy = [super copyWithZone:zone];
    
    copy.onAtStart = self.onAtStart;
    copy.frequency = self.frequency;
    
    return copy;
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [controllers addObject:[THVibrationBoardProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(THElementPinEditable*) minusPin{
    return [self.pins objectAtIndex:0];
}

-(THElementPinEditable*) digitalPin{
    return [self.pins objectAtIndex:1];
}

-(void) updateToPinValue{
    
    THElementPinEditable * pine = [self.pins objectAtIndex:1];
    THElementPin * pin = (THElementPin*) pine.simulableObject;
    THBoardPin * lilypadPin = (THBoardPin*) pin.attachedToPin;
    
    if(lilypadPin.type == kPintypeDigital){
        if(lilypadPin.value == kDigitalPinValueHigh && !self.on){
            [self turnOn];
        } else if(lilypadPin.value == kDigitalPinValueLow && self.on){
            [self turnOff];
        }
    } else if(lilypadPin.type == kPintypeAnalog){
        THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
        vibrationBoard.frequency = lilypadPin.value;
    }
}

-(void) update{

    if(self.on && !self.shaking){
        [self handleOn];
    } else if(!self.on && self.shaking){
        [self handleOff];
    }
}

-(CCAction*) shakeActionWithFrequency:(float) frequency{
    
    CGPoint displ = ccp(2,2);
    float duration = 6.0f/(float)self.frequency;
    
    CCMoveBy * move1 = [CCMoveBy actionWithDuration:duration position:ccp(displ.x, displ.y)];
    CCMoveBy * move2 = [CCMoveBy actionWithDuration:duration * 2 position:ccp(-displ.x, -displ.y)];
    CCSequence * sequence = [CCSequence actionOne:move1 two:move2];
    
    return [CCRepeatForever actionWithAction:sequence];
}

-(void) adaptVibrationFrequency{
    [self stopAction:_shakeAction];

    if(self.frequency > 0){
        _shakeAction = [self shakeActionWithFrequency:self.frequency];
        [self runAction:_shakeAction];
    }
}

-(BOOL) on{
    THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
    return vibrationBoard.on;
}

-(NSInteger) frequency{
    THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
    return vibrationBoard.frequency;
}

-(void) setFrequency:(NSInteger)frequency{
    
    THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
    vibrationBoard.frequency = frequency;
    if(self.on){
        [self adaptVibrationFrequency];
    }
}

-(void) handleOn{
    self.shaking = YES;
    [self adaptVibrationFrequency];
}

-(void) handleOff{
    self.shaking = NO;
    [self stopAction:_shakeAction];
}

- (void)turnOn{
    THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
    [vibrationBoard turnOn];
}

- (void)turnOff{
    THVibrationBoard * vibrationBoard = (THVibrationBoard*)self.simulableObject;
    [vibrationBoard turnOff];
}

-(NSString*) description{
    return @"VibeBoard";
}

@end
