//
//  LEBLManager.swift
//  swiftTest
//
//  Created by duowan123 on 2021/7/1.
//

import Foundation
import CoreBluetooth
import UIKit

//设备类型
public enum DEVICE_TYPE : Int {
    case TYPEMAIN//主设备
    case TYPEVICE //副设备
}

public class LEONBluetooth:UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate{

    // MARK: ------------------- 闭包的定义 --------------------------
    /// 蓝牙状态改变的block
    public typealias LEStateUpdateBlock = (CBCentralManager) -> Void
    /// 发现一个蓝牙外设的block
    public typealias LEDiscoverPeripheralBlock = (CBCentralManager, CBPeripheral, NSNumber) -> Void
    ///// 连接完成的block,失败error就不为nil
    //typedef void(^LEConnectCompletionBlock)(CBPeripheral *peripheral, NSError *error);

    /// 蓝牙连接成功的回调
    public typealias LEBluedConnectSuccessfulBlock = (CBPeripheral) -> Void
    /// 蓝牙链接失败的回调
    public typealias LEBluedConnectFailureBlock = (CBPeripheral) -> Void
    /// 蓝牙链接已经断开的回调
    public typealias LEBluedIsDisConnectBlock = (CBPeripheral) -> Void
    
    /// 搜索到服务block
    public typealias LEDiscoveredServicesBlock = (CBPeripheral, [CBService]) -> Void
    /// 搜索到某个服务中的特性的block
    public typealias LEDiscoverCharacteristicsBlock = (CBPeripheral, CBService, [CBCharacteristic]) -> Void
    
    /// 收到摸个特性中数据的回调
    public typealias LEReadValueForCharacteristicBlock = (CBPeripheral, CBCharacteristic, Data) -> Void
    /// 往特性中写入数据的回调
    public typealias LEWriteToCharacteristicBlock = (CBPeripheral?, CBCharacteristic?) -> Void

    //蓝牙外设
    public var stateUpdateBlock: LEStateUpdateBlock?
    public var discoverPeripheralBlock: LEDiscoverPeripheralBlock?
    //链接状态
    public var connectSuccessfulBlock: LEBluedConnectSuccessfulBlock?
    public var connectFailureBlock: LEBluedConnectFailureBlock?
    public var disConnectBlock: LEBluedIsDisConnectBlock?
    //蓝牙数据
    public var discoveredServicesBlock: LEDiscoveredServicesBlock? //
    public var discoverCharacteristicsBlock: LEDiscoverCharacteristicsBlock?
    public var readValueForCharacteristicBlock: LEReadValueForCharacteristicBlock?
    public var writeToCharacteristicBlock: LEWriteToCharacteristicBlock? //

    public var peripheral: CBPeripheral? //主设备
    public var vicePeripheral: CBPeripheral? //副设备

    //主设备 写入数据的特征 读取数据的特征
    public var write: CBCharacteristic?
    public var read: CBCharacteristic?
    //副设备 写入数据的特征 读取数据的特征
    public var viceWrite: CBCharacteristic?
    public var viceRead: CBCharacteristic?
    
    //单例
    public static let singleton = LEONBluetooth()

    //中心外设
    public var manager: CBCentralManager!
    
    //call init inity overring
    public func initCBCenterManager(){
//        manager = CBCentralManager.init(delegate: self, queue:.main)
        manager = CBCentralManager.init(delegate: self, queue: .main, options: [CBCentralManagerOptionShowPowerAlertKey:true])
    }

    // MARK: ------------------- CBCentralManagerDelegate --------------------------
    public func centralManagerDidUpdateState(_ central: CBCentralManager){
        
         var consoleLog = ""
         switch central.state{
         case .poweredOff:
             consoleLog = "BLE is powered off"
         case .poweredOn:
             consoleLog = "BLE is poweredOn"
         case .resetting:
             consoleLog = "BLE is resetting"
         case .unauthorized:
             consoleLog = "BLE is unauthorized"
         case .unknown:
             consoleLog = "BLE is unknown"
         case .unsupported:
             consoleLog = "BLE is unsupported"
         default:
             consoleLog = "default"
         }
         print(consoleLog)
        if self.stateUpdateBlock != nil {
            self.stateUpdateBlock!(central)
        }
                 
    }
    
    //扫描发现外设
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        guard  let deviceName = peripheral.name, deviceName.count > 0 else{
            return
        }
        
        if self.discoverPeripheralBlock != nil {
            self.discoverPeripheralBlock!(central,peripheral,RSSI)
        }

    }
    
    //已经建立连接
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        
        if self.connectSuccessfulBlock != nil{
            self.connectSuccessfulBlock!(peripheral)
            
            if peripheral == self.peripheral {//设备一
                self.peripheral!.delegate = self
                self.peripheral!.discoverServices(nil)
            }else  if peripheral == self.vicePeripheral {//设备二
                self.vicePeripheral!.delegate = self
                self.vicePeripheral!.discoverServices(nil)
            }
          
        }

    }
//import FacebookLogin
    //连接失败
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        if self.connectFailureBlock != nil && error == nil{
            self.connectFailureBlock!(peripheral)
        }
    }

    //连接丢失
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
                
        if self.disConnectBlock != nil && error == nil{
            self.disConnectBlock!(peripheral)
        }
    }

    // MARK: ------------------- CBPeripheralDelegate --------------------------
    //发现服务
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){

        if error == nil {
            
            if self.discoveredServicesBlock != nil {
                self.discoveredServicesBlock!(peripheral, peripheral.services!)
            }
            
            for service in peripheral.services!{
                self.peripheral!.discoverCharacteristics(nil, for:service)
            }
            
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?){

    }
    
    //发现特征
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
            
         //
            if self.discoverCharacteristicsBlock != nil && error == nil {
                self.discoverCharacteristicsBlock!(peripheral,service,service.characteristics!)
                
//                    //接收特征值
//                    for  cha in service.characteristics!{
//
//                        if cha.properties.rawValue == 16 {//读取设备1...n 的特征值 == 16
//                            
//                            if peripheral == self.peripheral {//设备1
//                                self.read = cha
//                                self.peripheral!.readValue(for: self.read!)
//                                self.peripheral!.setNotifyValue(true, for: self.read!)
//                                
//                            }else  if peripheral == self.vicePeripheral {//设备2
//                                self.viceRead = cha
//                                self.vicePeripheral!.readValue(for: self.viceRead!)
//                                self.vicePeripheral!.setNotifyValue(true, for: self.viceRead!)
//                            }
//                            
//                        }else if cha.properties.rawValue == 12 {//写的特征值 == 12
//                            
//                            if peripheral == self.peripheral {//设备1
//                                self.write = cha
//                            }else  if peripheral == self.vicePeripheral{//设备2
//                                self.viceWrite = cha
//                                
//                            }
//                       }
//                        
//                  }
                
            }
    }

    //读取特征的数据
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if self.readValueForCharacteristicBlock != nil && characteristic.value != nil{
            self.readValueForCharacteristicBlock!(peripheral,characteristic,characteristic.value!)
        }
    }
    
    //发送数据成功的回调
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        if self.writeToCharacteristicBlock != nil && characteristic.value != nil{
                self.writeToCharacteristicBlock!(peripheral,characteristic)
        }
    }
    
    
    // MARK: ------------------- 外部操作 --------------------------
    //建立蓝牙连接 在这里开始区分链接的哪台外设
    public func conntectPeripheral(peripheral: CBPeripheral,type:DEVICE_TYPE){
        
        if type == .TYPEMAIN {
            self.peripheral = peripheral
            self.manager.connect(self.peripheral!, options: nil)
        }else if type == .TYPEVICE{
            self.vicePeripheral = peripheral
            self.manager.connect(self.vicePeripheral!, options: nil)
        }

    }
    
    //断开蓝牙连接
    public func disConntectPeripheral(peripheral: CBPeripheral,type:DEVICE_TYPE){
        if type == .TYPEMAIN {
            self.manager.cancelPeripheralConnection(self.peripheral!)
//            self.peripheral?.delegate = nil
//            self.peripheral = nil
        }else if type == .TYPEVICE{
            self.manager.cancelPeripheralConnection(self.vicePeripheral!)
//            self.vicePeripheral?.delegate = nil
//            self.vicePeripheral = nil
        }
    }
    
}

    
