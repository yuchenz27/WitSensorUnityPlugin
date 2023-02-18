//
//  WitSensorUnityPlugin.h
//  WitSensorUnityPlugin
//
//  Created by Yuchen Zhang on 2023/2/16.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface WitSensorInterface : NSObject

+ (void)onFoundBluetoothDeviceWithKey:(int)index Name:(NSString *)deviceName;
+ (void)onBluetoothDeviceConnectedWithKey:(int)deviceKey Name:(NSString *)deviceName;
+ (void)onBluetoothDeviceDisconnectedWithKey:(int)deviceKey Name:(NSString *)deviceName;
+ (void)onReceivedBluetoothDeviceDataWithKey:(int)deviceKey Acceleration:(simd_float3)acceleration Angle:(simd_float3)angle Electricity:(float)electricity Temperature:(float)temperation;

@end
