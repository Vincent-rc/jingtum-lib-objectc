//
//  Remote.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/14.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>

extern NSString * const kWebSocketDidOpen;
extern NSString * const kWebSocketDidClose;
extern NSString * const kWebSocketdidReceiveMessage;

@interface Remote : NSObject

+ (Remote *)instance;

-(void)connectWithURLString:(NSString *)urlString local:(BOOL)isLocal;
-(void)disconnect;

-(void)requestServerInfo; // 获得井通底层的服务器信息
-(void)requestLedgerClosed; // 获得最新账本信息，包括区块高度 (ledger_index)与区块hash(ledger_hash)
-(void)requestLedger:(NSDictionary*)paramDic;
-(void)requestTx:(NSDictionary*)paramDic;
-(void)requestAccountInfo:(NSDictionary*)paramDic;
-(void)requestAccountTums:(NSDictionary*)paramDic;
-(void)requestAccountRelations:(NSDictionary*)paramDic;
-(void)requestAccountOffers:(NSDictionary*)paramDic;
-(void)requestAccountTx:(NSDictionary*)paramDic;
-(void)requestOrderBook:(NSDictionary*)paramDic;

@end
