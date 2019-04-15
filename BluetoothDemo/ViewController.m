//
//  ViewController.m
//  BluetoothDemo
//
//  Created by 唯赢 on 2019/4/12.
//  Copyright © 2019 李立. All rights reserved.
//
// 参考资料：http://liuyanwei.jumppo.com/2015/08/14/ios-BLE-2.html
//

#import "ViewController.h"
//#import <BabyBluetooth/BabyBluetooth.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBProgressHUD+Extension.h"
#import "Category/CBPeripheral+Extension.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    dispatch_queue_t _bluetoothQueue;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 中心模式 */
@property (strong, nonatomic) CBCentralManager *centralManager;
/** 当前连接的设备 */
@property (strong, nonatomic) CBPeripheral *currentPeripheral;
/** 设备列表 */
@property (strong, nonatomic) NSMutableArray <CBPeripheral *> *peripheralList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 准备工作，初始化中心管理器
    _peripheralList = [NSMutableArray new];
    _bluetoothQueue = dispatch_queue_create("demo.bluetoothQueue", NULL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_bluetoothQueue];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 中心模式状态改变的回调
    NSString *stateString = nil;
    if (CBCentralManagerStatePoweredOff == central.state) {
        NSLog(@"Bluetooth 关闭");
        stateString = @"Bluetooth 关闭";
    } else if (CBCentralManagerStatePoweredOn == central.state) {
        NSLog(@"Bluetooth 开启");
        stateString = @"Bluetooth 开启";
        // 开始扫描外设，只有设备处于打开状态才能扫描
        BOOL flag = (BOOL)self.peripheralList.count;
        [self.peripheralList removeAllObjects];
        if (flag) {
            [self reloadDataOnMainThread];
        }
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];   // 扫描
    } else if (CBCentralManagerStateUnknown == central.state) {
        NSLog(@"Bluetooth 未知状态");
        stateString = @"Bluetooth 未知状态";
    } else if (CBCentralManagerStateResetting == central.state) {
        NSLog(@"Bluetooth 设备重置");
        stateString = @"Bluetooth 设备重置";
    } else if (CBCentralManagerStateUnsupported == central.state) {
        NSLog(@"Bluetooth 设备不支持");
        stateString = @"Bluetooth 设备不支持";
    } else if (CBCentralManagerStateUnauthorized == central.state) {
        NSLog(@"Bluetooth 设备未授权");
        stateString = @"Bluetooth 设备未授权";
    } else {
        NSLog(@"Bluetooth 其他状态：%ld", central.state);
        stateString = @"Bluetooth 其他状态";
    }
    
    [self showText:stateString];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 扫描到设备的时候的回调方法
    
    // 过滤无效设备
    if (!peripheral.name.length || !peripheral.identifier) {
        return;
    }
    
    /// RSSI: 接收的信号强度指示
    
    // 检测是否添加过此设备
    for (CBPeripheral *p in self.peripheralList) {
        if ([peripheral.identifier.UUIDString isEqualToString:p.identifier.UUIDString]) {
            return; // 如果检测列表中存在此设备，就不加入列表中显示
        }
    }
    
    NSLog(@"设备名字：%@  信号强弱：%@ UUID: %@",peripheral.name ,RSSI, peripheral.identifier.UUIDString);
    // 加入列表中显示
    peripheral.rssiValue = RSSI;
    [self.peripheralList addObject:peripheral];
    // 更新列表
    [self reloadDataOnMainThread];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //连接外设成功
    [self showText:[NSString stringWithFormat:@"连接设备[%@]成功", peripheral.name]];
    // 设置当前设备
    self.currentPeripheral = peripheral;
    // 设置代理
    peripheral.delegate = self;
    // 开始发现服务??
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //外设连接失败
    [self showText:[NSString stringWithFormat:@"连接设备[%@]失败: %@", peripheral.name, error.userInfo[NSLocalizedDescriptionKey]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //断开外设
    [self showText:[NSString stringWithFormat:@"断开设备[%@]的连接", peripheral.name]];
}

- (void)reloadDataOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)showText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showText:text];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CBPeripheral *per = [self.peripheralList objectAtIndex:indexPath.row];
    cell.textLabel.text = per.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@dB", per.rssiValue];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *p = [self.peripheralList objectAtIndex:indexPath.row];
    // 先断开和上次的连接
    if (self.currentPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
        self.currentPeripheral = nil;
    }
    
    // 连接设备
    [self.centralManager connectPeripheral:p options:nil];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 已经发现服务
    [self showText:@"已经发现服务"];
    if (error) {
        return;
    }
    
    // 扫描每个 Service 的特征值 Characteristics
    for (CBService *service in peripheral.services) {
        // 去发现 Service 的特征值
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    // 从服务中发现了特征值
    if (error) {
        return;     // 错误
    }
    
    for (CBCharacteristic *c in service.characteristics) {
        // 读数据
        [peripheral readValueForCharacteristic:c];
        // 搜索 Descriptors
        [peripheral discoverDescriptorsForCharacteristic:c];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    
    NSLog(@"Characteristic [UPDATE VALUE] UUID:%@  value:%@",characteristic.UUID,characteristic.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 搜索到特征值的描述
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        NSLog(@"descriptor UUID:%@ value:%@", descriptor.UUID, descriptor.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    // 描述变化
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"descriptor UUIUD:%@ value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

@end
