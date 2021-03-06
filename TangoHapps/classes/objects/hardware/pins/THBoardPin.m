/*
THBoardPin.m
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

#import "THBoardPin.h"
#import "THElementPin.h"
#import "THHardwareComponent.h"

@implementation THBoardPin
@dynamic acceptsManyPins;

#pragma mark - Initialization

+(id) pinWithPinNumber:(NSInteger) pinNumber andType:(THPinType) type{
    return [[THBoardPin alloc] initWithPinNumber:pinNumber andType:type];
}

-(void) loadBoardPin{
    
    self.mode = kPinModeUndefined;
    _attachedElementPins = [NSMutableArray array];
    [self addPinObserver];
}

-(id) initWithPinNumber:(NSInteger) pinNumber andType:(THPinType) type{
    
    self = [super init];
    if(self){
        
        if(type == kPintypeAnalog || type == kPintypeDigital){
            self.number = pinNumber;
        }
        
        self.type = type;
        
        [self loadBoardPin];
    }
    return self;
}

-(id) init{
    self = [super init];
    if(self){
        [self loadBoardPin];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self){
        _attachedElementPins = [decoder decodeObjectForKey:@"attachedPins"];
        self.number = [decoder decodeIntegerForKey:@"number"];
        self.mode = [decoder decodeIntegerForKey:@"mode"];
        self.type = [decoder decodeIntegerForKey:@"type"];
        
        [self addPinObserver];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.attachedElementPins forKey:@"attachedPins"];
    [coder encodeInteger:self.number forKey:@"number"];
    [coder encodeInteger:self.mode forKey:@"mode"];
    [coder encodeInteger:self.type forKey:@"type"];
    
}

-(id)copyWithZone:(NSZone *)zone {
    
    THBoardPin * copy = [super copyWithZone:zone];
    
    copy.number = self.number;
    copy.type = self.type;
    copy.mode = self.mode;
    copy.value = self.value;
    
    return copy;
}

#pragma mark - Methods

-(void) setValueWithoutNotifications:(NSInteger) value{
    
    [self removePinObserver];
    
    self.value = value;
    
    [self addPinObserver];
}

-(BOOL) acceptsManyPins{
    return (self.type == kPintypeMinus || self.type == kPintypePlus || self.supportsSDA || self.supportsSCL);
}

-(void) attachPin:(THElementPin*) pin{
    if(!self.acceptsManyPins && self.attachedElementPins.count == 1){
        THElementPin * pin = [self.attachedElementPins objectAtIndex:0];
        [pin deattach];
        
        [self.attachedElementPins removeAllObjects];
    }
    
    if(self.type != kPintypeMinus && self.type != kPintypePlus && self.mode == kPinModeUndefined){
        self.mode = pin.defaultBoardPinMode;
    }
    
    [self.attachedElementPins addObject:pin];
}

-(void) deattachPin:(THElementPin*) pin{
    [self.attachedElementPins removeObject:pin];
    
    if(self.attachedElementPins.count == 0){
        self.mode = kPinModeUndefined;
    }
}

-(BOOL) isClotheObjectAttached:(THHardwareComponent*) object{
    for (THElementPin * pin in self.attachedElementPins) {
        if(pin.hardware == object){
            return YES;
        }
    }
    return NO;
}

#pragma mark - Pin Observing & Value Notification

-(void) removePinObserver{

    [self removeObserver:self forKeyPath:@"value"];
}

-(void) addPinObserver{

    [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

//important: if you set the value directly, the hardware will be notified. This should happen for input coming from the real hardware.
//if the hardware itself is setting the value, use the setValueWithoutNotifications, otherwise you will get an infinite recursive loops and stack overflow
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"value"]){
        [self notifyNewValue];
    }
}

-(void) notifyNewValue{
    
    for (THElementPin * pin in self.attachedElementPins) {
        [pin.hardware handlePin:self changedValueTo:self.value];
    }
}

-(NSString*) description{
    
    NSString * text;
    if(self.type == kPintypeMinus || self.type == kPintypePlus){
        text = [NSString stringWithFormat:@"(%@) pin",kPinTexts[self.type]];
    } else {
        text = [NSString stringWithFormat:@"pin %ld (%@)",(long)self.number, kPinTexts[self.type]];
    }
    
    return text;
}

-(void) prepareToDie{
    _attachedElementPins = nil;
    
    [super prepareToDie];
}

-(void) dealloc{
    
    [self removePinObserver];
}

@end


