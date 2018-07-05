//
//  keypairs.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface keypairs : NSObject

-(NSString*)generateSeed;
-(NSString*)deriveKeyPair:(NSString*)secret;

@end
