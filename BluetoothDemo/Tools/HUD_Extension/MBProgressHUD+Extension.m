//
//  MBProgressHUD+Extension.m
//  BluetoothDemo
//
//  Created by 唯赢 on 2019/4/12.
//  Copyright © 2019 李立. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

+ (instancetype)showText:(NSString *)text {
    return [self showText:text afterDelay:1];
}

+ (instancetype)showError:(NSError *)error {
    NSString *msg = error.userInfo[NSLocalizedDescriptionKey];
    if (msg.length) {
        return [MBProgressHUD showText:msg];
    }
    
    return nil;
}

+ (instancetype)showText:(NSString *)text afterDelay:(NSTimeInterval)delay
{
    return [self showText:text toView:[UIApplication sharedApplication].keyWindow afterDelay:delay];
}

+ (instancetype)showText:(NSString *)text toView:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [self showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    CGPoint offset = CGPointMake(hud.xOffset, hud.yOffset);
    offset.y = ([UIScreen mainScreen].bounds.size.height/2.0f)*(0.53973013);
    hud.yOffset = offset.y;
    [hud hide:YES afterDelay:delay];
    
    return hud;
}

@end
