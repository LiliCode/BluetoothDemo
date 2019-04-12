//
//  MBProgressHUD+Extension.h
//  BluetoothDemo
//
//  Created by 唯赢 on 2019/4/12.
//  Copyright © 2019 李立. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (Extension)

/**
 显示文字，1秒后消失

 @param text 需要显示的文字
 @return MBProgressHUD
 */
+ (instancetype)showText:(NSString *)text;

/**
 显示 NSError 对象中的错误消息

 @param error NSError 对象
 @return MBProgressHUD
 */
+ (instancetype)showError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
