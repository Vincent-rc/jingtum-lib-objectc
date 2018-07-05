//
//  Remote.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/14.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Remote.h"
#import "Transaction.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


NSString * const kWebSocketDidOpen           = @"kWebSocketDidOpen";
NSString * const kWebSocketDidClose          = @"kWebSocketDidClose";
NSString * const kWebSocketdidReceiveMessage = @"kWebSocketdidReceiveMessage";

@implementation Remote

@synthesize isLocal;
@synthesize tx;

+(Remote *)instance{
    static Remote *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[Remote alloc] init];
    });
    
    return Instance;
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)sendData:(id)data {
    NSLog(@"socketSendData --------------- %@",data);
    
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("sendata", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
            } else {
                NSLog(@"the state isn`t open ");
            }
        } else {
            NSLog(@"we have no network");
        }
    });
}

#pragma mark - socket delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳，暂时先不做心跳？是否需要发送这个心跳呢？
//    [self initHeartBeat];
    
    if (webSocket == self.socket) {
        NSLog(@"************************** successfully connect socket ********************* ");
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidOpen object:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket fail************************** ");
        _socket = nil;
        //连接失败就重连
//        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket break ************************** ");
//        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
//        [self SRWebSocketClose];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidClose object:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** receive data from socket************************** ");
//        NSLog(@"message: %@", message);
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketdidReceiveMessage object:message];
        if (tx != nil) {
            [tx sign:message];
        }
    }
}

#pragma mark - **************** public methods
-(void)connectWithURLString:(NSString *)urlString local:(BOOL)isLocal {
    
    //如果是同一个url return
    if (self.socket) {
        return;
    }
    
    if (!urlString) {
        return;
    }
    
    self.isLocal = isLocal;
    
    self.urlString = urlString;
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    NSLog(@"the websocket address is：%@", self.socket.url.absoluteString);
    
    self.socket.delegate = self;   //SRWebSocketDelegate 协议
    
    [self.socket open];     //开始连接
}

-(void)disconnect
{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
    }
}

-(void)requestServerInfo
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:1];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"server_info" forKey:@"command"]; // server_info
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestLedgerClosed
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:1];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"ledger_closed" forKey:@"command"]; // ledger_closed
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(BOOL)isValidHash:(NSString*)ledger_hash
{
    return true;
}

-(BOOL)isValidAddress:(NSString*)address
{
    return true;
}

-(BOOL)isValidAmount0:(NSDictionary*)dic
{
    return true;
}

-(void)requestLedger:(NSDictionary*)paramDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:1];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"ledger" forKey:@"command"]; // ledger
    
    // 把参数填进来
    NSObject *ledger_index = [paramDic objectForKey:@"ledger_index"];
    if (ledger_index != nil) {
        [dic setObject:ledger_index forKey:@"ledger_index"];
    }
    NSString *ledger_hash = [paramDic objectForKey:@"ledger_hash"]; // 需要验证是否是合法的hash
    if (ledger_hash != nil && [self isValidHash:ledger_hash]) {
        [dic setObject:ledger_hash forKey:@"ledger_hash"];
    }
    // 以下四个都是 bool 型哦
    NSObject *full = [paramDic objectForKey:@"full"];
    if (full != nil) {
        [dic setObject:full forKey:@"full"];
    }
    NSObject *expand = [paramDic objectForKey:@"expand"];
    if (expand != nil) {
        [dic setObject:expand forKey:@"expand"];
    }
    NSObject *transactions = [paramDic objectForKey:@"transactions"];
    if (transactions != nil) {
        [dic setObject:transactions forKey:@"transactions"];
    }
    NSObject *accounts = [paramDic objectForKey:@"accounts"];
    if (accounts != nil) {
        [dic setObject:accounts forKey:@"accounts"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestTx:(NSDictionary*)paramDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:1];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"tx" forKey:@"command"]; // tx
    
    // 把参数填进来
    NSString *hash = [paramDic objectForKey:@"hash"];
    if (hash != nil && [self isValidHash:hash]) {
        [dic setObject:hash forKey:@"transaction"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestAccount:(NSMutableDictionary*)dic param:(NSDictionary*)paramDic
{
    // 把参数填进来
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil) {
        [dic setObject:account forKey:@"account"];
    }
    id ledger = [paramDic objectForKey:@"ledger"];
    if (ledger != nil) {
        if ([ledger isKindOfClass:[NSString class]]) {
            [dic setObject:ledger forKey:@"ledger_index"];
        } else if ([ledger isKindOfClass:[NSNumber class]]) {
            [dic setObject:ledger forKey:@"ledger_index"];
        }
    } else {
        [dic setObject:@"validated" forKey:@"ledger_index"];
    }
    NSString *peer = [paramDic objectForKey:@"peer"];
    if (peer != nil && [self isValidAddress:peer]) {
        [dic setObject:peer forKey:@"peer"];
    }
    NSNumber *limit = [paramDic objectForKey:@"limit"];
    if (limit != nil) {
        if (limit < 0) {
            limit = 0;
        }
        //        if (limit > 1000000000) {
        //            limit = 1000000000;
        //        }
        [dic setObject:limit forKey:@"limit"];
    }
    NSString *marker = [paramDic objectForKey:@"marker"];
    if (marker != nil) {
        [dic setObject:marker forKey:@"marker"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestAccountInfo:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_info" forKey:@"command"]; // account_info
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account");
    }
}

-(void)requestAccountTums:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_currencies" forKey:@"command"]; // account_currencies
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account");
    }
}

-(void)requestAccountRelations:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *type = [paramDic objectForKey:@"type"];
    if (type != nil && account != nil) {
        BOOL isValid = true;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        
        if ([type isEqualToString:@"trust"]) {
            [dic setObject:@"account_lines" forKey:@"command"]; // account_lines
        } else if ([type isEqualToString:@"authorize"] || [type isEqualToString:@"freeze"]) {
            [dic setObject:@"account_relation" forKey:@"command"]; // account_relation
        } else {
            isValid = false;
        }
        
        if (isValid) {
            [self requestAccount:dic param:paramDic];
        } else {
            NSLog(@"the type is invalid");
        }
    } else {
        // 出错啦
        NSLog(@"without the type");
    }
}

-(void)requestAccountOffers:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_offers" forKey:@"command"]; // account_offers
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account");
    }
}

-(void)requestAccountTx:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_tx" forKey:@"command"]; // account_tx
        
        if ([self isValidAddress:account]) {
            [dic setObject:account forKey:@"account"];
            NSNumber *ledger_min = [paramDic objectForKey:@"ledger_min"];
            if (ledger_min != nil) {
                [dic setObject:ledger_min forKey:@"ledger_index_min"];
            } else {
                NSNumber *zero = [NSNumber numberWithInt:0];
                [dic setObject:zero forKey:@"ledger_index_min"];
            }
            NSNumber *ledger_max = [paramDic objectForKey:@"ledger_max"];
            if (ledger_max != nil) {
                [dic setObject:ledger_max forKey:@"ledger_index_max"];
            } else {
                NSNumber *zero = [NSNumber numberWithInt:-1];
                [dic setObject:zero forKey:@"ledger_index_max"];
            }
            NSNumber *limit = [paramDic objectForKey:@"limit"];
            if (limit != nil) {
                [dic setObject:limit forKey:@"limit"];
            }
            NSNumber *offset = [paramDic objectForKey:@"offset"];
            if (offset != nil) {
                [dic setObject:offset forKey:@"offset"];
            }
            NSDictionary *marker = [paramDic objectForKey:@"marker"];
            if (marker != nil) {
//                NSNumber *ledger = [marker objectForKey:@"ledger"];
//                NSNumber *seq = [marker objectForKey:@"seq"];
                [dic setObject:marker forKey:@"marker"];
            }
            // 以下是 bool 类型的哦
            NSObject *forward = [paramDic objectForKey:@"forward"];
            if (forward != nil) {
                [dic setObject:forward forKey:@"forward"];
            }
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"json string: %@", json);
            
            [self sendData:json];
        } else {
            NSLog(@"account parameter is invalid");
        }
    } else {
        NSLog(@"without the account");
    }
}

//{"id":1,"command":"book_offers","taker_gets":{"currency":"CNY","issuer":"jBciDE8Q3uJjf111VeiUNM775AMKHEbBLS"},"taker_pays":{"currency":"SWT","issuer":""},"taker":"jjjjjjjjjjjjjjjjjjjjBZbvri"}
-(void)requestOrderBook:(NSDictionary*)paramDic
{
    NSDictionary *gets = [paramDic objectForKey:@"gets"];
    NSDictionary *pays = [paramDic objectForKey:@"pays"];
    NSObject *taker_gets = [paramDic objectForKey:@"taker_gets"];
    NSObject *taker_pays = [paramDic objectForKey:@"taker_pays"];
    if (gets != nil && pays != nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"book_offers" forKey:@"command"]; // book_offers
        
        if (taker_gets != nil) {
            if ([self isValidAmount0:taker_gets]) {
                [dic setObject:taker_gets forKey:@"taker_gets"];
            }
        } else {
            if ([self isValidAmount0:gets]) {
                [dic setObject:gets forKey:@"taker_gets"];
            }
        }
        
        if (taker_pays != nil) {
            if ([self isValidAmount0:taker_pays]) {
                [dic setObject:taker_pays forKey:@"taker_pays"];
            }
        } else {
            if ([self isValidAmount0:pays]) {
                [dic setObject:pays forKey:@"taker_pays"];
            }
        }
        
        NSObject *taker = [paramDic objectForKey:@"taker"];
        if (taker != nil) {
            [dic setObject:taker forKey:@"taker"];
        } else {
            // utils.ACCOUNT_ONE
            [dic setObject:@"jjjjjjjjjjjjjjjjjjjjBZbvri" forKey:@"taker"];
        }
        NSObject *limit = [paramDic objectForKey:@"limit"];
        if (limit != nil) {
            [dic setObject:limit forKey:@"limit"];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string: %@", json);
        
        [self sendData:json];
    } else {
        NSLog(@"invalid taker gets amount");
    }
}

-(void)buildPaymentTx:(NSDictionary *)paramDic
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *destination = [paramDic objectForKey:@"destination"];
    NSString *to = [paramDic objectForKey:@"to"];
    NSDictionary *amount = [paramDic objectForKey:@"amount"];
    
    NSString *secret = [paramDic objectForKey:@"secret"];
    NSString *memo = [paramDic objectForKey:@"memo"];
    
    NSString *src = nil;
    NSString *dst = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    if (destination != nil) {
        dst = destination;
    } else if (to != nil) {
        dst = to;
    }
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return;
    }
    if (![self isValidAddress:dst]) {
        NSLog(@"invalid destination address");
        return;
    }
    if (![self isValidAddress:account]) { // ????????????
        NSLog(@"invalid amount");
        return;
    }
    
    tx = [[Transaction alloc] init];
    tx.remote = self;
    
    [tx setSecret:secret];
    [tx addMemo:memo];
    
    [tx submit:src];
}

@end
