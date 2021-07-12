# LEONBluetooth

[![CI Status](https://img.shields.io/travis/leonStraightMen/LEONBluetooth.svg?style=flat)](https://travis-ci.org/leonStraightMen/LEONBluetooth)
[![Version](https://img.shields.io/cocoapods/v/LEONBluetooth.svg?style=flat)](https://cocoapods.org/pods/LEONBluetooth)
[![License](https://img.shields.io/cocoapods/l/LEONBluetooth.svg?style=flat)](https://cocoapods.org/pods/LEONBluetooth)
[![Platform](https://img.shields.io/cocoapods/p/LEONBluetooth.svg?style=flat)](https://cocoapods.org/pods/LEONBluetooth)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LEONBluetooth is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LEONBluetooth'
```

## Author

leonStraightMen, dengzf.ok@163.com

## License

LEONBluetooth is available under the MIT license. See the LICENSE file for more info.

## How To Usage
#### initCBCentralManager
```swift
    //单例
    let singleton = LEONBluetooth.singleton
    //初始化外设中心管理类
    singleton.initCBCenterManager()
```
#### CBManagerState
```swift
    //蓝牙状态更新
    singleton.stateUpdateBlock = {
        (central:CBCentralManager) -> Void in
        print(central.state.rawValue)
        if central.state.rawValue == 5 {
            singleton.manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
```
#### discoverPeripheral && connectPeripheral
```swift
    //发现设备
    singleton.discoverPeripheralBlock = {
        (central:CBCentralManager, peripheral:CBPeripheral, rssi:NSNumber)->Void in
    //            print("发现蓝牙外设 \(peripheral)")
        if let name = peripheral.name,name .hasPrefix("SH_"){
            singleton.conntectPeripheral(peripheral: peripheral, type:.TYPEMAIN)
        }else  if let name = peripheral.name,name .hasPrefix("SH_2"){
            singleton.conntectPeripheral(peripheral: peripheral, type:.TYPEVICE)
        }
    }
```

#### disConnectPeripheral
```swift
    //单例
    let singleton = LEONBluetooth.singleton
    if singleton.peripheral != nil {
        singleton.disConntectPeripheral(peripheral:singleton.peripheral!, type: .TYPEMAIN)
    }
    if singleton.vicePeripheral != nil {
        singleton.disConntectPeripheral(peripheral:singleton.vicePeripheral!, type: .TYPEVICE)
    }
```

#### connectState
```swift
    //链接成功
    singleton.connectSuccessfulBlock = {
        (peripheral:CBPeripheral) -> Void in
        if peripheral == singleton.peripheral {
            print("设备一：链接成功")
        }else if peripheral == singleton.vicePeripheral {
            print("设备二：链接成功")
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
```

#### discoverServices && discoverCharacteristics
```swift
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
            if peripheral == singleton.peripheral {
                print("设备一: 发现特征 \(characteristic)")
            }else if peripheral == singleton.vicePeripheral {
                print("设备二: 发现特征 \(characteristic)")
            }
        }
```

#### readValueForCharacteristic
```swift
    //读取特征的数据
    singleton.readValueForCharacteristicBlock = {
        (peripheral:CBPeripheral,characteristic:CBCharacteristic,data:Data) -> Void in
        if peripheral == singleton.peripheral {
            print("设备一: 读取到的数据 \(data as NSData)")
        }else if peripheral == singleton.vicePeripheral {
            print("设备二: 读取到的数据 \(data as NSData)")
        }
    }
```
#### writeValue
```swift
    //测试写入数据
    let bytes:[UInt8] = [0xaa,0x02,0xf8,0xA5,0x2,0x4c]
    let data = NSData(bytes: bytes, length: bytes.count)
    print("发送数据 \(data)")
    //单例
    let singleton = LEONBluetooth.singleton
    singleton.peripheral?.writeValue(data as Data, for: singleton.write!, type:.withResponse)

```

