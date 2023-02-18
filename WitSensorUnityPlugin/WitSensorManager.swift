//
//  WitSensorManager.swift
//  WitSensorUnityPlugin
//
//  Created by Yuchen Zhang on 2023/2/16.
//

import Foundation
import WitSDK
import simd

class WitSensorManager : NSObject, IBluetoothEventObserver, IBwt901bleRecordObserver {
    
    // This class is a singleton
    @objc static let shared = WitSensorManager()
    
    var bluetoothManager = WitBluetoothManager.instance
    
    @objc var isScanning: Bool = false
    
    var browsedDeviceCount: Int = 0
    
    // The dict of browsed nearby devices
    var browsedDeviceDict:[Int:Bwt901ble] = [Int:Bwt901ble]()
    
    var connectedDeviceCount: Int = 0
    
    // The dict of connected devices
    var connectedDeviceDict:[Int:Bwt901ble] = [Int:Bwt901ble]()
    
    @objc func startScanning() {
        self.browsedDeviceCount = 0
        self.browsedDeviceDict.removeAll()
        
        self.bluetoothManager.registerEventObserver(observer: self)
        self.bluetoothManager.startScan()
        self.isScanning = true
        print("Started scanning")
    }
    
    @objc func stopScanning() {
        self.browsedDeviceCount = 0
        self.browsedDeviceDict.removeAll()
        
        self.bluetoothManager.stopScan()
        self.isScanning = false
        print("Stopped scanning")
    }
    
    @objc func connectDevice(_ deviceKey: Int) {
        if let device = browsedDeviceDict[deviceKey] {
            connectDeviceInternal(bwt901ble: device)
        } else {
            print("There is no bluetooth device in the dict with key \(deviceKey)")
        }
    }
    
    func connectDeviceInternal(bwt901ble: Bwt901ble) {
        do {
            try bwt901ble.openDevice()
            bwt901ble.registerListenKeyUpdateObserver(obj: self)
            print("Connected with bluetooth device \(String(describing: bwt901ble.name))")
            
            let deviceKey = self.connectedDeviceCount
            self.connectedDeviceCount += 1
            self.connectedDeviceDict[deviceKey] = bwt901ble
            WitSensorInterface.onBluetoothDeviceConnected(withKey: Int32(deviceKey), name: String(describing: bwt901ble.name))
        } catch {
            print("Failed to connect device")
        }
    }
    
// MARK: Delegate Helpers
    
    // Returns true if this device has not been found yet
    func isNotFound(_ bluetoothBLE: BluetoothBLE?) -> Bool {
        for device in browsedDeviceDict.values {
            if device.mac == bluetoothBLE?.mac {
                return false
            }
        }
        return true
    }
    
// MARK: IBluetoothEventObserver
    
    // Invoked when a Bluetooth Low Energy sensor is found
    func onFoundBle(bluetoothBLE: WitSDK.BluetoothBLE?) {
        if isNotFound(bluetoothBLE) {
            print("Found a bluetooth device: \(String(describing: bluetoothBLE?.peripheral.name))")
            let deviceKey = self.browsedDeviceCount
            self.browsedDeviceCount += 1
            self.browsedDeviceDict[deviceKey] = Bwt901ble(bluetoothBLE: bluetoothBLE)
            WitSensorInterface.onFoundBluetoothDevice(withKey: Int32(deviceKey), name: String(describing: bluetoothBLE?.peripheral.name))
        }
    }
    
    // Invoked when the connection is successful
    func onConnected(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("Connected with bluetooth device: \(String(describing: bluetoothBLE?.peripheral.name))")
    }
    
    // Invoked when the connection fails
    func onConnectionFailed(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("Failed to connect bluetooth device: \(String(describing: bluetoothBLE?.peripheral.name))")
    }
    
    // Invoked when the connection is lost
    func onDisconnected(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("Disconnected with bluetooth device: \(String(describing: bluetoothBLE?.peripheral.name))")
    }
    
// MARK: IBwt901bleRecordObserver
    func onRecord(_ bwt901ble: WitSDK.Bwt901ble) {
        
        guard let deviceKey = self.connectedDeviceDict.first(where: { $0.value.mac == bwt901ble.mac })?.key else {
            return
        }
        
        let accX = bwt901ble.getDeviceData(WitSensorKey.AccX) ?? ""
        let accY = bwt901ble.getDeviceData(WitSensorKey.AccY) ?? ""
        let accZ = bwt901ble.getDeviceData(WitSensorKey.AccZ) ?? ""
        
        let angX = bwt901ble.getDeviceData(WitSensorKey.AngleX) ?? ""
        let angY = bwt901ble.getDeviceData(WitSensorKey.AngleY) ?? ""
        let angZ = bwt901ble.getDeviceData(WitSensorKey.AngleZ) ?? ""
        
        let elec = bwt901ble.getDeviceData(WitSensorKey.ElectricQuantityPercentage) ?? ""
        let temp = bwt901ble.getDeviceData(WitSensorKey.Temperature) ?? ""

        if let accelerationX = Float(accX), let accelerationY = Float(accY), let accelerationZ = Float(accZ),
           let angleX = Float(angX), let angleY = Float(angY), let angleZ = Float(angZ),
           let electricity = Float(elec), let temperation = Float(temp) {
            let acceleration = SIMD3<Float>(arrayLiteral: accelerationX, accelerationY, accelerationZ)
            let angle = SIMD3<Float>(arrayLiteral: angleX, angleY, angleZ)
            
            WitSensorInterface.onReceivedBluetoothDeviceData(withKey: Int32(deviceKey), acceleration: acceleration, angle: angle, electricity: electricity, temperature: temperation)
        }
    }
}
