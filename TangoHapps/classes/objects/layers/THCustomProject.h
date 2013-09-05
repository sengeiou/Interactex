//
//  THCustomProject.h
//  TangoHapps
//
//  Created by Juan Haladjian on 11/28/12.
//  Copyright (c) 2012 Technische Universität München. All rights reserved.
//

#import "TFProject.h"

@class THHardwareComponentEditableObject;
@class THiPhoneEditableObject;
@class THViewEditableObject;
@class THClothe;
@class THLilyPadEditable;
@class THiPhoneEditableObject;
@class THClientProject;
@class THAssetCollection;
@class THWire;
@class THElementPinEditable;
@class THBoardPinEditable;

@interface THCustomProject : TFProject
{
    
}

//init
+(id) newProject;
+(id) projectNamed:(NSString*) name;

//pin
-(void) pinClotheObject:(THHardwareComponentEditableObject*) clotheObject toClothe:(THClothe*) clothe;
-(void) unpinClotheObject:(THHardwareComponentEditableObject*) clotheObject;

//iPhone
-(void) addiPhone:(THiPhoneEditableObject *)iPhone;
-(void) removeiPhone;

//iPhone objects
-(void) addiPhoneObject:(THViewEditableObject*) object;
-(void) removeiPhoneObject:(THViewEditableObject*) object;
-(THViewEditableObject*) iPhoneObjectAtLocation:(CGPoint) location;

//clotheObjects
-(void) addClotheObject:(THHardwareComponentEditableObject*) clotheObject;
-(void) removeClotheObject:(THHardwareComponentEditableObject*) clotheObject;
-(THHardwareComponentEditableObject*) clotheObjectAtLocation:(CGPoint) location;
-(void) tryAttachClotheObject: (THHardwareComponentEditableObject*) clotheObject;

//clothes
-(void) addClothe:(THClothe*) object;
-(void) removeClothe:(THClothe*) object;
-(THClothe*) clotheAtLocation:(CGPoint) location;

//condition
-(void) addCondition:(TFEditableObject*) condition;
-(void) removeCondition:(TFEditableObject*) condition;
-(TFEditableObject*) conditionAtLocation:(CGPoint) location;

//values
-(void) addValue:(TFEditableObject*) condition;
-(void) removeValue:(TFEditableObject*) condition;
-(TFEditableObject*) valueAtLocation:(CGPoint) location;

//triggers
-(void) addTrigger:(TFEditableObject*) trigger;
-(void) removeTrigger:(TFEditableObject*) trigger;
-(TFEditableObject*) triggerAtLocation:(CGPoint) location;

//actions
-(void) addAction:(TFEditableObject*) action;
-(void) removeAction:(TFEditableObject*) action;
-(TFEditableObject*) actionAtLocation:(CGPoint) location;

//lilypad
-(void) addLilypad:(THLilyPadEditable *)lilypad;
-(void) removeLilypad;

//wires
-(void) addWire:(THWire*) wire;
-(void) removeWire:(THWire*) wire;
-(void) addWireFrom:(THElementPinEditable*) elementPin to:(THBoardPinEditable*) boardPin;
-(void) removeAllWiresTo:(id) object;

//non editable project
-(THClientProject*) nonEditableProject;

@property (nonatomic,readonly) THLilyPadEditable * lilypad;
@property (nonatomic,readonly) THiPhoneEditableObject * iPhone;
@property (nonatomic,readonly) NSMutableArray * hardwareComponents;
@property (nonatomic,readonly) NSMutableArray * clothes;
@property (nonatomic,readonly) NSMutableArray * iPhoneObjects;
@property (nonatomic,readonly) NSMutableArray * conditions;
@property (nonatomic,readonly) NSMutableArray * values;
@property (nonatomic,readonly) NSMutableArray * triggers;
@property (nonatomic,readonly) NSMutableArray * actions;
@property (nonatomic, readonly) NSMutableArray * wires;

@property (nonatomic,readonly) THAssetCollection * assetCollection;

@end
