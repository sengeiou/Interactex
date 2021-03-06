/*
 BLEDiscovery.h
 BLE
 
 Created by Juan Haladjian on 11/06/2013.
 
 BLE is a library used to send and receive data from/to a device over Bluetooth 4.0.
 
 www.interactex.org
 
 Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
 
 Contacts:
 juan.haladjian@cs.tum.edu
 katharina.bredies@udk-berlin.de
 opensource@telekom.de
 
 
 It has been created with funding from EIT ICT, as part of the activity "Connected Textiles".
 
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>

#import "BLEService.h"

@protocol BLEDiscoveryDelegate <NSObject>
@required
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
- (void) peripheralDiscovered:(CBPeripheral*) peripheral;
@end


@interface BLEDiscovery : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
	CBCentralManager    *centralManager;
	BOOL				pendingInit;
}

+(instancetype) sharedInstance;

-(void) startScanningForSupportedUUIDs;
-(void) startScanningForAnyUUID;
-(void) startScanningForUUIDString:(NSString *)uuidString;
-(void) stopScanning;

-(void) connectPeripheral:(CBPeripheral*)peripheral;
-(void) disconnectCurrentPeripheral;


@property (nonatomic, readonly) NSMutableArray * supportedServiceUUIDs;
@property (nonatomic, readonly) NSMutableArray * supportedCharacteristicUUIDs;

@property (nonatomic, weak) id<BLEDiscoveryDelegate>  discoveryDelegate;
@property (nonatomic, weak) id<BLEServiceDelegate> peripheralDelegate;

@property (nonatomic, strong) NSMutableArray * foundPeripherals;
@property (nonatomic, readonly) BLEService * connectedService;
@property (nonatomic, readonly) CBPeripheral * currentPeripheral;

@end
