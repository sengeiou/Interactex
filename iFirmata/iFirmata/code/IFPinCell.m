//
//  IFPinCell.m
//  iFirmata
//
//  Created by Juan Haladjian on 6/27/13.
//  Copyright (c) 2013 TUM. All rights reserved.
//

#import "IFPinCell.h"
#import "IFPin.h"
#import <QuartzCore/QuartzCore.h>

@implementation IFPinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier pin:(IFPin*) pin {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.pin = pin;
        
        [self relayout];
    }
    return self;
}

-(void) setPin:(IFPin *)pin{
    if(_pin != pin){
        if(pin){
            [_pin removeObserver:self forKeyPath:@"value"];
            [_pin removeObserver:self forKeyPath:@"updatesValues"];
            
            [pin addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
            [pin addObserver:self forKeyPath:@"updatesValues" options:NSKeyValueObservingOptionNew context:nil];
        }
        _pin = pin;
        [self relayout];
    }
}

-(void) relayout{
    
    [self setLabelText];
    [self reloadPinModeControls];
}

#pragma mark -- GUI Setup

-(void) setLabelText{
    
    if(self.pin.type == IFPinTypeDigital){
        self.label.text = @"D";
    } else {
        self.label.text = @"A";
    }
    
    self.label.text = [self.label.text stringByAppendingFormat:@"%d",self.pin.number];
}

-(void) addDigitalButton{
    
    //CGRect segmentFrame = CGRectMake(175, 10, 130, 33);
    self.digitalControl.hidden = NO;
    
    /*
    NSArray * items = [NSArray arrayWithObjects:@"LOW",@"HIGH",nil];
    
    self.digitalControl = [[UISegmentedControl alloc] initWithItems:items];
    
    self.digitalControl.selectedSegmentIndex = self.pin.value;
    self.digitalControl.frame = segmentFrame;
    
    [self.digitalControl addTarget:self action:@selector(digitalControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.digitalControl];*/
}

-(void) addValueLabel{
    self.valueLabel.hidden = NO;
    /*
    CGRect labelFrame = CGRectMake(220, 10, 82, 35);
    
    self.valueLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.valueLabel.layer.borderWidth = 1.0f;
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.valueLabel];*/
}

-(void) addSlider{
    self.slider.hidden = NO;
    /*
    CGRect sliderFrame = CGRectMake(175, 8, 135, 35);
    
    self.slider = [[UISlider alloc] initWithFrame:sliderFrame];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 255;
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.slider];*/
}

-(void) removeControls{
    if(self.digitalControl){
        self.digitalControl.hidden = YES;
        //[self.digitalControl removeFromSuperview];
    }
    
    if(self.valueLabel){
        self.valueLabel.hidden = YES;
        //[self.valueLabel removeFromSuperview];
    }
    
    if(self.slider){
        self.slider.hidden = YES;
        //[self.slider removeFromSuperview];
    }
}

-(void) reloadPinModeControls{
    [self removeControls];
    
    if(self.pin.type == IFPinTypeDigital){
        if(self.pin.mode == IFPinModeOutput){
            
            [self addDigitalButton];
            self.modeControl.selectedSegmentIndex = 1;
        } else if(self.pin.mode == IFPinModeInput){
            
            [self addValueLabel];
            [self updateDigitalLabel];
        } else if(self.pin.mode == IFPinModePWM){
            
            self.modeControl.selectedSegmentIndex = 3;
            [self addSlider];
            [self updateSlider];
            
        } else if(self.pin.mode == IFPinModeServo){
            
            self.modeControl.selectedSegmentIndex = 2;
            [self addSlider];
        }
    } else {
        
        //self.modeControl.selectedSegmentIndex = 2;
        self.valueLabel.layer.borderWidth = 1.0f;
        
        //[self addAnalogSwitch];
        //[self addValueLabel];
    }
}

#pragma mark -- Update

-(void) updateDigitalLabel{
    self.valueLabel.text = (self.pin.value == 0 ? @"LOW" : @"HIGH");
}

-(void) updateAnalogLabel{
    self.analogValueLabel.text = [NSString stringWithFormat:@"%d",self.pin.value];
}

-(void) updateSlider{
    self.slider.value = self.pin.value;
}

-(IBAction) segmentedControlChanged:(UISegmentedControl*) sender{
    if(self.pin.type == IFPinTypeDigital){
        self.pin.mode = sender.selectedSegmentIndex;
        
    } else {
        if(sender.selectedSegmentIndex == 2){
            self.pin.mode = IFPinModeAnalog;
        } else {
            self.pin.mode = sender.selectedSegmentIndex;
        }
    }
    
    [self reloadPinModeControls];
}

- (IBAction)analogSwitchChanged:(UISwitch*)sender {
    
    [self.pin removeObserver:self forKeyPath:@"updatesValues"];
    self.pin.updatesValues = sender.on;
    if(!self.pin.updatesValues){
        self.analogValueLabel.text = @"";
    }
    [self.pin addObserver:self forKeyPath:@"updatesValues" options:NSKeyValueObservingOptionNew context:nil];
}

-(IBAction) digitalControlChanged:(UISegmentedControl*) sender{
    [self.pin removeObserver:self forKeyPath:@"value"];
    self.pin.value = sender.selectedSegmentIndex;
    [self.pin addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

-(IBAction) sliderChanged:(UISlider*) sender{
    
    if(sender.value == 0 || fabs(self.pin.value - sender.value) > 10){
        [self.pin removeObserver:self forKeyPath:@"value"];
        self.pin.value = sender.value;
        [self.pin addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark -- Keyvalue coding

-(void) handlePinValueChanged:(IFPin*) pin{
    if(pin.mode == IFPinModeInput){
        [self updateDigitalLabel];
    } else if(pin.mode == IFPinModeAnalog){
        if(pin.updatesValues){
            [self updateAnalogLabel];
        }
    } else if(pin.mode == IFPinModePWM){
        [self updateSlider];
    }
}

-(void) handlePinUpdatesValuesChanged:(IFPin*) pin{
    if(pin.mode == IFPinModeAnalog){
        self.analogSwitch.on = pin.updatesValues;
        if(!pin.updatesValues){
            self.analogValueLabel.text = @"";
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath  ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqual:@"value"]){
        
        [self handlePinValueChanged:object];
    } else if([keyPath isEqual:@"updatesValues"]){
        
        [self handlePinUpdatesValuesChanged:object];
    }
}

-(void) dealloc{
    
    [self.pin removeObserver:self forKeyPath:@"value"];
    [self.pin removeObserver:self forKeyPath:@"updatesValues"];
}

@end
