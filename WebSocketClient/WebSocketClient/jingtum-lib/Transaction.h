//
//  Transaction.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/24.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Remote.h"

@class Remote;

@interface Transaction : NSObject

@property (nonatomic, retain) Remote *remote;

-(void)setSecret:(NSString*)secret;
-(void)addMemo:(NSString*)memo;
-(void)submit:(NSString*)src;
-(void)sign:(id)message;

@end
