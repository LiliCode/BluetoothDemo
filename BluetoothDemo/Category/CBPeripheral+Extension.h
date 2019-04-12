//
//  CBPeripheral+Extension.h
//  BluetoothDemo
//
//  Created by 唯赢 on 2019/4/12.
//  Copyright © 2019 李立. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (Extension)
@property (strong, nonatomic) NSNumber *rssiValue;

@end

NS_ASSUME_NONNULL_END
