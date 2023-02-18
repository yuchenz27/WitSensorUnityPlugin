//
//  WitSensorUnityPlugin.m
//  WitSensorUnityPlugin
//
//  Created by Yuchen Zhang on 2023/2/16.
//

#import "WitSensorInterface.h"
#import "WitSensorUnityPlugin-Swift.h"

void (*OnFoundBluetoothDevice)(int, const char *) = NULL;
void (*OnBluetoothDeviceConnected)(int, const char *) = NULL;
void (*OnBluetoothDeviceDisconnected)(int, const char *) = NULL;
void (*OnReceivedBluetoothDeviceData)(int, float *) = NULL;

@implementation WitSensorInterface

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)onFoundBluetoothDeviceWithKey:(int)deviceKey Name:(NSString *)deviceName {
    if (OnFoundBluetoothDevice != NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OnFoundBluetoothDevice(deviceKey, [deviceName UTF8String]);
        });
    }
}

+ (void)onBluetoothDeviceConnectedWithKey:(int)deviceKey Name:(NSString *)deviceName {
    if (OnBluetoothDeviceConnected != NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OnBluetoothDeviceConnected(deviceKey, [deviceName UTF8String]);
        });
    }
}

+ (void)onBluetoothDeviceDisconnectedWithKey:(int)deviceKey Name:(NSString *)deviceName {
    if (OnBluetoothDeviceDisconnected != NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OnBluetoothDeviceDisconnected(deviceKey, [deviceName UTF8String]);
        });
    }
}

+ (void)onReceivedBluetoothDeviceDataWithKey:(int)deviceKey Acceleration:(simd_float3)acceleration Angle:(simd_float3)angle Electricity:(float)electricity Temperature:(float)temperature {
    if (OnReceivedBluetoothDeviceData != NULL) {
        float *data  = new float[8];
        data[0] = acceleration.x;
        data[1] = acceleration.y;
        data[2] = acceleration.z;
        data[3] = angle.x;
        data[4] = angle.y;
        data[5] = angle.z;
        data[6] = electricity;
        data[7] = temperature;
        dispatch_async(dispatch_get_main_queue(), ^{
            OnReceivedBluetoothDeviceData(deviceKey, data);
            delete[](data);
        });
    }
}

@end

# pragma mark - extern "C"

extern "C" {
    
void WitSensor_InitCallbacks(void (*onFoundBluetoothDeviceCallback)(int, const char *),
                             void (*onBluetoothDeviceConnectedCallback)(int, const char *),
                             void (*onBluetoothDeviceDisconnectedCallback)(int, const char *),
                             void (*onReceivedBluetoothDeviceDataCallback)(int, float *)) {
    OnFoundBluetoothDevice = onFoundBluetoothDeviceCallback;
    OnBluetoothDeviceConnected = onBluetoothDeviceConnectedCallback;
    OnBluetoothDeviceDisconnected = onBluetoothDeviceDisconnectedCallback;
    OnReceivedBluetoothDeviceData= onReceivedBluetoothDeviceDataCallback;
}
    
void WitSensor_StartScanning(void) {
    [[WitSensorManager shared] startScanning];
}
    
void WitSensor_StopScanning(void) {
    [[WitSensorManager shared] stopScanning];
}
    
bool WitSensor_IsScanning(void) {
    return [[WitSensorManager shared] isScanning];
}
    
void WitSensor_ConnectDevice(int deviceKey) {
    [[WitSensorManager shared] connectDevice:deviceKey];
}
    
}
