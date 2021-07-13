//
//  ViewController.swift
//  LEONBluetooth
//
//  Created by leonStraightMen on 07/09/2021.
//  Copyright (c) 2021 leonStraightMen. All rights reserved.
//

import UIKit
import LEONBluetooth
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var disConnectButtion: UIButton!
    @IBOutlet weak var sendDataButton: UIButton!

    //override
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.title = "Test Bluetooth"
        
        self.sendDataButton.addTarget(self, action: #selector(writerData), for:.touchUpInside)
        self.disConnectButtion.addTarget(self, action: #selector(disConnect), for:.touchUpInside)

        //单例
        let singleton = LEONBluetooth.singleton
        
        //初始化外设中心管理类
        singleton.initCBCenterManager()
        
        //蓝牙状态更新
        singleton.stateUpdateBlock = {
            (central:CBCentralManager) -> Void in
            print(central.state.rawValue)
            if central.state.rawValue == 5 {
                singleton.manager.scanForPeripherals(withServices: nil, options: nil)
            }
        }
        
        //发现设备
        singleton.discoverPeripheralBlock = {
            (central:CBCentralManager, peripheral:CBPeripheral, rssi:NSNumber)->Void in
//            print("发现蓝牙外设 \(peripheral)")
            if let name = peripheral.name,name .hasPrefix("SH_"){
                singleton.conntectPeripheral(peripheral: peripheral, type:.TYPEMAIN)
                print("设备一：发起链接")
            }else  if let name = peripheral.name,name .hasPrefix("SH_2"){
                singleton.conntectPeripheral(peripheral: peripheral, type:.TYPEVICE)
                print("设备二：发起链接")
            }
        }
        
        //链接成功
        singleton.connectSuccessfulBlock = {
            (peripheral:CBPeripheral) -> Void in
            if peripheral == singleton.peripheral {
                print("设备一：链接成功 \(peripheral)")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二：链接成功 \(peripheral)")
            }
        }
        
        //链接失败
        singleton.connectFailureBlock = {
            (peripheral:CBPeripheral)->Void in
            if peripheral == singleton.peripheral {
                print("设备一：链接失败")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二：链接失败")
            }
        }
        
        //链接丢失
        singleton.disConnectBlock = {
            (peripheral:CBPeripheral)->Void in
            if peripheral == singleton.peripheral {
                print("设备一：链接丢失")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二：链接丢失")
            }
        }
        
        //发现服务
        singleton.discoveredServicesBlock = {
            (peripheral:CBPeripheral,services:[CBService]) -> Void in
            if peripheral == singleton.peripheral {
                print("设备一: 发现服务 \(services)")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二: 发现服务 \(services)")
            }
        }

        //发现特征
        singleton.discoverCharacteristicsBlock = {
            (peripheral:CBPeripheral,service:CBService, characteristic:[CBCharacteristic]) -> Void in
            
            //接收并且保存特质值
            for  cha in service.characteristics!{

                if cha.properties.rawValue == 16 {//读取设备1...n 的特征值 == 16
                    
                    if peripheral == singleton.peripheral {//设备1
                        print("设备一: 发现 - 读取特征 \(characteristic)")
                        singleton.read = cha
                        singleton.peripheral!.readValue(for: singleton.read!)
                        singleton.peripheral!.setNotifyValue(true, for: singleton.read!)
                        
                    }else  if peripheral == singleton.vicePeripheral {//设备2
                        singleton.viceRead = cha
                        singleton.vicePeripheral!.readValue(for: singleton.viceRead!)
                        singleton.vicePeripheral!.setNotifyValue(true, for: singleton.viceRead!)
                        print("设备二: 发现 - 读取特征 \(characteristic)")

                    }
                    
                }else if cha.properties.rawValue == 12 {//写的特征值 == 12
                    
                    if peripheral == singleton.peripheral {//设备1
                        print("设备一: 发现 - 写入特征 \(characteristic)")

                        singleton.write = cha
                    }else  if peripheral == singleton.vicePeripheral{//设备2
                        singleton.viceWrite = cha
                        print("设备二: 发现 - 写入特征 \(characteristic)")

                    }
               }
                
          }
            
       
        }

        //读取特征的数据
        singleton.readValueForCharacteristicBlock = {
            (peripheral:CBPeripheral,characteristic:CBCharacteristic,data:Data) -> Void in
            if peripheral == singleton.peripheral {
                print("设备一: 读取到的数据 \(data as NSData)")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二: 读取到的数据 \(data as NSData)")
            }
        }
        
        //写入特征值后的反馈
        
        
    }
    
    //测试发送数据
    @objc func writerData(){
        //测试写入数据
        let bytes:[UInt8] = [0xaa,0x06,0xf9,0xA2,0x1,0x4c]
        let data = NSData(bytes: bytes, length: bytes.count)
        print("设备一:发送数据 \(data)")
        //单例
        let singleton = LEONBluetooth.singleton
        singleton.peripheral?.writeValue(data as Data, for: singleton.write!, type:.withResponse)

    }


    //测试断开蓝牙
    @objc func disConnect(){
        //单例
        let singleton = LEONBluetooth.singleton
        if singleton.peripheral != nil {
            singleton.disConntectPeripheral(peripheral:singleton.peripheral!, type: .TYPEMAIN)
            print("设备一:断开链接")
        }
        if singleton.vicePeripheral != nil {
            singleton.disConntectPeripheral(peripheral:singleton.vicePeripheral!, type: .TYPEVICE)
            print("设备二:断开链接")

        }
    }
    
    
  
}

