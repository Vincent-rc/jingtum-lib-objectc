//
//  Transaction.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/24.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

@synthesize remote;

-(void)setSecret:(NSString *)secret
{
    NSLog(@"we are in setSecret %@", secret);
}

-(void)addMemo:(NSString *)memo
{
    NSLog(@"we are in addMemo %@", memo);
}

-(void)submit:(NSString*)src
{
    NSLog(@"we are in submit");
    if (remote.isLocal) {
        //
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:src forKey:@"account"];
        [dic setObject:@"trust" forKey:@"type"];
        
        [remote requestAccountInfo:dic];
    }
}

-(void)sign:(id)message
{
    // 本地签名
    NSString *msg = (NSString*)message;
    NSLog(@"in transaction the msg is %@", msg);
    NSData *jsonData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"fail to parse the message %@", msg);
        return;
    }
    
    NSDictionary *account_data = [dic objectForKey:@"account_data"];
    if (account_data != nil) {
        NSNumber *Sequence = [account_data objectForKey:@"account_data"];
    }
}

@end
