//
//  ViewController.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/5/15.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "ViewController.h"
#import "SocketRocketUtility.h"
#import "Remote.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [[SocketRocketUtility instance] SRWebSocketOpenWithURLString:@"ws://123.57.219.57:5020"];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpenNote object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketDidCloseNote object:nil];
    
    // 连接
    [[Remote instance] connectWithURLString:@"ws://123.57.219.57:5020" local:true];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessage object:nil];
}

- (void)SRWebSocketDidOpen {
    NSLog(@"connect socket successfully");
    //在成功后需要做的操作。。。类似于 nodejs 里面的回调函数
//    [[Remote instance] requestServerInfo];
//    [[Remote instance] requestLedgerClosed];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    /*
     以下是有带上 ledger_index 和 transactions 的结果
     {"id":1,"result":{"ledger":{"accepted":true,"account_hash":"4EBB072B32DCFEF566A161681BE2CB1D9FE8C4346735D32563E62695377AAFAC","close_time":582261250,"close_time_human":"2018-Jun-14 03:14:10","close_time_resolution":10,"closed":true,"hash":"2B99A41121399637BD53486FDAE5C8BB141185E7ADE5EE39BED5F5674013F585","ledger_hash":"2B99A41121399637BD53486FDAE5C8BB141185E7ADE5EE39BED5F5674013F585","ledger_index":"483718","parent_hash":"043F5631861109A1D3C737F7DD13AFB27F213BED97F749D45C2A1376C7D56FA1","seqNum":"483718","totalCoins":"600000000000000000","total_coins":"600000000000000000","transaction_hash":"0000000000000000000000000000000000000000000000000000000000000000","transactions":[]},"ledger_hash":"2B99A41121399637BD53486FDAE5C8BB141185E7ADE5EE39BED5F5674013F585","ledger_index":483718,"validated":false},"status":"success","type":"response"}
     以下是没有带上 ledger_index 和 transactions 的结果
     {"id":1,"result":{"closed":{"ledger":{"accepted":true,"account_hash":"AC9CB5052C1396DA4B948479EE4B20410E92892B7128F0BEE35F40DDCEA085BC","close_time":582265690,"close_time_human":"2018-Jun-14 04:28:10","close_time_resolution":10,"closed":true,"hash":"3F2765DD93FD1A192752360068670F11164D6DCB0C3E1088D724CFF79B71222A","ledger_hash":"3F2765DD93FD1A192752360068670F11164D6DCB0C3E1088D724CFF79B71222A","ledger_index":"484162","parent_hash":"AA9BAE206881975E225E4B582B99034FF2108A730E5235AE5357351F0975232F","seqNum":"484162","totalCoins":"600000000000000000","total_coins":"600000000000000000","transaction_hash":"0000000000000000000000000000000000000000000000000000000000000000"}},"open":{"ledger":{"closed":false,"ledger_index":"484163","parent_hash":"3F2765DD93FD1A192752360068670F11164D6DCB0C3E1088D724CFF79B71222A","seqNum":"484163"}}},"status":"success","type":"response"}
     */
//    NSNumber *ledger_index = [NSNumber numberWithInt:483718];
//    NSNumber *transactions = [NSNumber numberWithBool:YES];
//
//    [dic setObject:ledger_index forKey:@"ledger_index"];
//    [dic setObject:transactions forKey:@"transactions"];
//
//    [[Remote instance] requestLedger:dic];
    
    //////////////////////////
    // 这边传入的是 交易hash 哦！！！！
//    [dic setObject:@"A4C52EF5A3075BF6169BA0AC716BF26A989B97BEDE53DC3BA1C252CF1338E0C7" forKey:@"hash"];
//    [[Remote instance] requestTx:dic];
    
    //////////////////////////
//    [dic setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
//    [[Remote instance] requestAccountInfo:dic];
    
    //////////////////////////
//    [dic setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
//    [[Remote instance] requestAccountTums:dic];
    
    //////////////////////////
//    [dic setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
//    [dic setObject:@"trust" forKey:@"type"];
//    [[Remote instance] requestAccountRelations:dic];
    
    //////////////////////////
//    [dic setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
//    [[Remote instance] requestAccountOffers:dic];
    
    //////////////////////////
//    [dic setObject:@"jB7rxgh43ncbTX4WeMoeadiGMfmfqY2xLZ" forKey:@"account"];
//    [[Remote instance] requestAccountTx:dic];
    
    //////////////////////////
//    NSMutableDictionary *gets = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *pays = [[NSMutableDictionary alloc] init];
//    [gets setObject:@"SWT" forKey:@"currency"];
//    [gets setObject:@"" forKey:@"issuer"];
//    [pays setObject:@"CNY" forKey:@"currency"];
//    [pays setObject:@"jBciDE8Q3uJjf111VeiUNM775AMKHEbBLS" forKey:@"issuer"];
//    [dic setObject:gets forKey:@"gets"];
//    [dic setObject:pays forKey:@"pays"];
//    NSNumber *limit = [NSNumber numberWithInteger:2];
//    [dic setObject:limit forKey:@"limit"];
//    [[Remote instance] requestOrderBook:dic];

}

- (void)SRWebSocketDidReceiveMsg:(NSNotification *)note {
    //收到服务端发送过来的消息
    NSString * message = note.object;
    NSLog(@"the response from server is: %@", message);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
