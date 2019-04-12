//
//  CBPeripheral+Extension.m
//  BluetoothDemo
//
//  Created by 唯赢 on 2019/4/12.
//  Copyright © 2019 李立. All rights reserved.
//

#import "CBPeripheral+Extension.h"
#import <objc/runtime.h>

@implementation CBPeripheral (Extension)

- (void)setRssiValue:(NSNumber *)rssiValue {
    objc_setAssociatedObject(self, @selector(rssiValue), rssiValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)rssiValue {
    return objc_getAssociatedObject(self, _cmd);
}

@end
