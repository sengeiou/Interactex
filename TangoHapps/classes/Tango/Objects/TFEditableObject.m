/*
TFEditableObject.m
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

#import "TFEditableObject.h"
#import "TFConnectionLine.h"
#import "THInvocationConnectionLine.h"

#import "THEditableObjectProperties.h"
#import "TFSimulableObject.h"
#import "TFMethod.h"
#import "TFEvent.h"
#import "TFProperty.h"

#import "THPropertiesPropertyController.h"
#import "THMethodsPropertyController.h"
#import "THEventPropertyController.h"
#import "THPaletteItem.h"
#import "THEditableObjectCommonProperties.h"

#import "THHardwareComponentEditableObject.h"
#import "THProgrammingElementEditable.h"

@implementation TFEditableObject

@dynamic paletteItem;

static NSInteger objectCount = 1;


-(void) loadEditableObject{
    
    self.canBeScaled = YES;
    self.anchorPoint = ccp(0.5,0.5);
    self.visible = YES;
    self.highlightColor = kDefaultObjectHighlightColor;
    self.canBeDuplicated = YES;
    self.canBeAddedToPalette = NO;
    self.canBeMoved = YES;
    self.canBeDeleted = YES;
    objectCount++;
}

-(id) init{
    
    self = [super init];
    
    if(self){
        
        self.myScale = 1.0f;
        self.myRotation = 0.0f;
        self.active = YES;
        
        self.z = kDefaultZ;
        [self loadEditableObject];
    }
    
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if(self){
        
        [self loadEditableObject];
        
        self.active = [decoder decodeBoolForKey:@"active"];
        self.myScale = [decoder decodeFloatForKey:@"scale"];
        self.myRotation = [decoder decodeFloatForKey:@"rotation"];
        self.position = [decoder decodeCGPointForKey:@"position"];
        self.size = [decoder decodeCGSizeForKey:@"size"];
        self.z = [decoder decodeIntForKey:@"z"];
        self.simulableObject = [decoder decodeObjectForKey:@"object"];
        self.acceptsConnections = [decoder decodeBoolForKey:@"acceptsConnections"];
        self.objectName = [decoder decodeObjectForKey:@"objectName"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeBool:self.active forKey:@"active"];
    [coder encodeFloat:self.myScale forKey:@"scale"];
    [coder encodeFloat:self.myRotation forKey:@"rotation"];
    [coder encodeCGPoint:self.position forKey:@"position"];
    [coder encodeCGSize:self.size forKey:@"size"];
    [coder encodeInteger:self.z forKey:@"z"];
    [coder encodeObject:self.simulableObject forKey:@"object"];
    [coder encodeBool:self.acceptsConnections forKey:@"acceptsConnections"];
    [coder encodeObject:self.objectName forKey:@"objectName"];
}

-(id)copyWithZone:(NSZone *)zone {
    
    TFEditableObject * copy = [[[self class] alloc] init];
    
    copy.active = self.active;
    copy.myScale = self.myScale;
    copy.myRotation = self.myRotation;
    copy.position = self.position;
    
    return copy;
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    
    NSMutableArray * array = [NSMutableArray array];
    
    if(self.properties.count > 0){
        _propertiesPropertyController = [THPropertiesPropertyController properties];
        [array addObject:_propertiesPropertyController];
    }
    
    if(self.events.count > 0){
        _eventsPropertyController = [THEventPropertyController properties];
        [array addObject:_eventsPropertyController];
    }
    
    if(self.methods.count > 0){
        _methodsPropertyController = [THMethodsPropertyController properties];
        [array addObject:_methodsPropertyController];
    }
    
    return array;
}

#pragma mark - Methods

-(void) update{
    
}

-(TFMethod*) methodNamed:(NSString*) methodName{
    for (TFMethod * method in self.methods) {
        if([method.name isEqualToString:methodName]){
            return method;
        }
    }
    return nil;
}

-(TFEvent*) eventNamed:(NSString*) eventName{
    for (TFEvent * event in self.events) {
        if([event.name isEqualToString:eventName]){
            return event;
        }
    }
    return nil;
}


#pragma mark - Connections

-(BOOL) acceptsConnectionsTo:(TFEditableObject*)object{
    
    for (TFEvent * event in self.events) {
        for (TFMethod * method in object.methods) {
            if([event canTriggerMethod:method]){
                return YES;
            }
        }
    }
    
    for (TFProperty * property in self.properties) {
        if([object acceptsPropertiesOfType:property.type]){
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Actions

-(void) handleRegisteredAsSourceForAction:(TFAction*) action{
}

-(void) handleRegisteredAsTargetForAction:(TFAction*) action{
}

#pragma mark - Properties

-(BOOL) acceptsPropertiesOfType:(TFDataType)type{
    return [self.simulableObject acceptsPropertiesOfType:type];
}


#pragma mark - Getters

-(NSMutableArray*) properties{
    return self.simulableObject.properties;
}

-(NSMutableArray*) events{
    if(!_events){//lazy init of events with references to local editable object
        _events = [NSMutableArray array];
        for (TFEvent * event in self.simulableObject.events) {
            TFEvent * copy = [event copy];
            copy.param1.target = self;
            [_events addObject:copy];
        }
    }
    return _events;
}

-(NSMutableArray*) methods{

    return self.simulableObject.methods;
}

#pragma mark - Methods

-(void) loadSprites{
    
}

-(void) setVisible:(BOOL)visible{
    TFSimulableObject * simulable = (TFSimulableObject*) self.simulableObject;
    simulable.visible = visible;
    [super setVisible:visible];
}

-(THPaletteItem*) paletteItem{
    THPaletteItem * paletteItem = [[THPaletteItem alloc] initWithName:@"customPaletteItem"];
    return paletteItem;
}

-(void) updateContentSize{

    self.contentSize = self.sprite.contentSize;
}

-(void) setSprite:(CCSprite *)sprite{
    if(_sprite != sprite){
        _sprite = sprite;
        _sprite.anchorPoint = ccp(0,0);
        [self updateContentSize];
    }
}

-(void) addToLayer:(TFLayer*) layer{

}

-(void) removeFromLayer:(TFLayer*) layer{

}

-(void) addToWorld{
    
}

-(void) removeFromWorld {
    [self prepareToDie];
}

-(void) setWidth:(float) width{
    _size.width = width;
}

-(float) width{
    return _size.width;
}

-(void) setHeight:(float) height{
    _size.height = height;
}

-(float) height{
    return _size.height;
}

-(void) setSize:(CGSize)size{
    _size = size;
}

-(void)scaleBy:(CGFloat)scaleDx {
    self.myScale *= scaleDx;
}

-(void)rotateBy:(CGFloat)aFloat {
    self.myRotation += aFloat;
}

-(void)displaceBy:(CGPoint)displacement {
    self.position = ccpAdd(self.position, displacement);
    
}

-(void) setPosition:(CGPoint)position{
    
    [super setPosition:position];
    //NSLog(@"%f %f",position.x,position.y);
}

-(void) reloadProperties{
    [self.eventsPropertyController reloadState];
    [self.propertiesPropertyController reloadState];
    [self.methodsPropertyController reloadState];
}

-(CGRect) boundingBox{
        
    if(_sprite){
        CGPoint spriteLoc = [_sprite convertToWorldSpace:CGPointZero];
        return CGRectMake(spriteLoc.x, spriteLoc.y, _sprite.contentSize.width * self.myScale * self.parent.scale, _sprite.contentSize.height * self.myScale * self.parent.scale);
    } else {
        CGPoint spriteLoc = [self convertToWorldSpace:CGPointZero];
        
        CGSize size = CGSizeMake(self.contentSize.width * self.myScale * self.parent.scale, self.contentSize.height * self.myScale * self.parent.scale);
        return CGRectMake(spriteLoc.x - size.width / 2, spriteLoc.y - size.height / 2, size.width, size.height);
    }
}

-(CGPoint) absolutePosition{
    return [self convertToWorldSpace:ccp(0,0)];
}

-(CGPoint) center{
    CGRect box = self.boundingBox;
    return ccp(box.origin.x + box.size.width/2, box.origin.y + box.size.height/2);
}

#pragma mark - UI

-(void) handleObjectOverlapping:(TFEditableObject*) object{
    
}

-(void) handleObjectStoppedOverlapping{
    
}

-(void) handleDroppedObject:(TFEditableObject*) object position:(CGPoint) position{
    
}

-(BOOL)testPoint:(CGPoint)point {
    if(!self.visible) return NO;
    
    CGRect box = self.boundingBox;
    
    CGPoint origin = box.origin;
    
    CGRect rect;
    rect.origin = origin;
    rect.size = box.size;
    rect.size = CGSizeMake(rect.size.width, rect.size.height);
    
    return CGRectContainsPoint(rect, point);
}

-(BOOL) canBeMovedBy:(CGPoint) d{
    if(!self.canBeMoved){
        return NO;
    }
    
    return YES;
}

-(void) handleTouchBegan{
}

-(void) handleTouchEnded{
}

-(void) handleTouchMovedTo:(CGPoint) location{
    
}

-(void) draw {
    
    if(self.selected || self.highlighted){
        
        glLineWidth(1);
        
        if(self.highlighted){
            glLineWidth(2);
            ccDrawColor4B(self.highlightColor.r, self.highlightColor.g, self.highlightColor.b, self.highlightColor.a);
            
        } else {
            ccDrawColor4B(kDefaultObjectSelectionColor.r, kDefaultObjectSelectionColor.g, kDefaultObjectSelectionColor.b, kDefaultObjectSelectionColor.a);
        }
        
        float const kSelectionPadding = 5;
        
        CGRect box = self.boundingBox;
        CGSize rectSize = CGSizeMake(self.contentSize.width + kSelectionPadding * 2, self.contentSize.height + kSelectionPadding * 2);
        
        CGPoint point = box.origin;
        point = [self convertToNodeSpace:point];
        point = ccpSub(point, ccp(kSelectionPadding, kSelectionPadding));
                
        ccDrawRect(point, ccp(point.x + rectSize.width, point.y + rectSize.height));
    }
}


-(void) addSelectionLabel{
    
    _selectionLabel = [CCLabelTTF labelWithString:self.shortDescription fontName:kSimulatorDefaultFont fontSize:9 dimensions:CGSizeMake(70, 20) hAlignment:kCCVerticalTextAlignmentCenter];
    
    _selectionLabel.position = ccp(0,_sprite.contentSize.height/2 + 15);
    [self addChild:_selectionLabel z: 1];
}

#pragma mark - Name Label

-(void) updateNameLabel{
    if([self isKindOfClass:[THHardwareComponentEditableObject class]] || [self isKindOfClass:[THProgrammingElementEditable class]]){
        CGSize const kEditableObjectNameLabelSize = {100,20};
        
        if(self.nameLabel){
            [self.nameLabel removeFromParentAndCleanup:YES];
        }
        
        self.nameLabel = [CCLabelTTF labelWithString:self.objectName fontName:kSimulatorDefaultBoldFont fontSize:11 dimensions:kEditableObjectNameLabelSize hAlignment:kCCVerticalTextAlignmentCenter];
        
        self.nameLabel.color = ccBLACK;
        //self.nameLabel.color = ccWHITE;
        //self.nameLabel.position = ccp(self.contentSize.width/2,-20);
        self.nameLabel.position = ccp(25,-20);
        
        [self addChild:self.nameLabel];
    }
}

-(void) setObjectName:(NSString *)objectName{
    if(![self.objectName isEqualToString:objectName]){
        _objectName = objectName;
        
        [self updateNameLabel];
    }
}

-(void) refreshUI{

    [self updateNameLabel];
}

#pragma mark - Lifecycle

-(void) willStartSimulation {
    self.selected = NO;
        
    [self.simulableObject willStartSimulating];
}

-(void) didStartSimulation {
    [self.simulableObject didStartSimulating];
}

-(void) willStartEdition {
    
}

-(void) handleTap{}

-(void) handleRotation:(CGFloat) degree{}

-(void) prepareToDie{
        
    _eventsPropertyController = nil;
    _propertiesPropertyController = nil;
    _methodsPropertyController = nil;
    
    [self.simulableObject prepareToDie];
    _simulableObject = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString*) shortDescription{
    return @"";
}

-(NSString*) description{
    return @"Editable Object";
}

-(void) dealloc{
    objectCount--;
    if ([@"YES" isEqualToString: [[[NSProcessInfo processInfo] environment] objectForKey:@"printDeallocsEditableObjects"]]) {
        NSLog(@"deallocing %@",self);
    }
}

@end
