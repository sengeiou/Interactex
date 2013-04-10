//
//  THLilyPad.m
//  TangoHapps
//
//  Created by Juan Haladjian on 10/11/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THLilyPad.h"
#import "THBoardPin.h"

@implementation THLilyPad
@dynamic minusPin;
@dynamic plusPin;

-(void) load{    
    _numberOfDigitalPins = 14;
    _numberOfAnalogPins = 6;
}

-(void) setPwmPins{
    for (int i = 0; i < kLilypadNumPwmPins; i++) {
        NSInteger pinIdx = kLilypadPwmPins[i];
        THBoardPin * boardpin = [self digitalPinWithNumber:pinIdx];
        boardpin.isPWM = YES;
    }
}

-(void) loadPins{
    for (int i = 0; i <= 4; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i andType:kPintypeDigital];
        [_pins addObject:pin];
    }
    
    THBoardPin * minusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypeMinus];
    [_pins addObject:minusPin];
    
    THBoardPin * plusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypePlus];
    [_pins addObject:plusPin];
    
    for (int i = 7; i <= 15; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i-2 andType:kPintypeDigital];
        [_pins addObject:pin];
    }
    
    for (int i = 16; i < kLilypadNumberOfPins; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i-16 andType:kPintypeAnalog];
        [_pins addObject:pin];
    }
    
    [self setPwmPins];
}

-(id) init{
    self = [super init];
    if(self){
        
        _pins = [NSMutableArray array];
        [self load];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    _pins = [decoder decodeObjectForKey:@"pins"];
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_pins forKey:@"pins"];
}

-(id)copyWithZone:(NSZone *)zone {
    THLilyPad * copy = [super copyWithZone:zone];
    
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:_pins.count];
    for (THPin * pin in _pins) {
        THPin * copy = [pin copy];
        [array addObject:copy];
    }
    copy.pins = array;
    
    return copy;
}

#pragma mark - Methods

-(THBoardPin*) minusPin{
    return [_pins objectAtIndex:5];
}

-(THBoardPin*) plusPin{
    return [_pins objectAtIndex:6];
}

-(NSInteger) realIdxForPin:(THBoardPin*) pin{
    
    if(pin.type == kPintypeDigital){
        return pin.number;
    } else {
        return pin.number + self.numberOfDigitalPins;
    }
}

-(THBoardPin*) pinWithRealIdx:(NSInteger) pinNumber{
    NSInteger pinidx;
    
    if(pinNumber <= self.numberOfDigitalPins){
        return [self digitalPinWithNumber:pinNumber];
    } else {
        return [self analogPinWithNumber:pinNumber - self.numberOfDigitalPins];
    }
    return [self.pins objectAtIndex:pinidx];
}

-(NSInteger) pinIdxForPin:(NSInteger) pinNumber ofType:(THPinType) type{
    if(type == kPintypeDigital){
        if(pinNumber <= 4) {
            return pinNumber;
        } else if(pinNumber <= self.numberOfDigitalPins){
            return pinNumber + 2;
        }
        
        return pinNumber;
    } else if(type == kPintypeAnalog){
        if(pinNumber >= 0 && pinNumber <= 5){
            return pinNumber + 16;
        }
    } else if(type == kPintypeMinus){
        return 5;
    } else if(type == kPintypePlus){
        return 6;
    }
    
    return -1;
}

-(THBoardPin*) digitalPinWithNumber:(NSInteger) number{
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeDigital];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

-(THBoardPin*) analogPinWithNumber:(NSInteger) number{
    
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeAnalog];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

-(NSArray*) objectsAtPin:(NSInteger) pinNumber{
    THBoardPin * pin = _pins[pinNumber];
    return pin.attachedPins;
}

-(void) attachPin:(THElementPin*) object atPin:(NSInteger) pinNumber{
    THBoardPin * pin = _pins[pinNumber];
    [pin attachPin:object];
}

-(NSString*) description{
    return @"lilypad";
}

-(void) prepareToDie{
    for (THBoardPin * pin in self.pins) {
        [pin prepareToDie];
    }
    _pins = nil;
    [super prepareToDie];
}

@end
