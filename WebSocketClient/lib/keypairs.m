//
//  keypairs.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/7/1.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "keypairs.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"

@implementation keypairs

-(NSString*)generateSeed
{
    char bytes[17];
    int SEED_PREFIX = 33;
    bytes[0] = (char)SEED_PREFIX;
    for (int x = 1; x < 17; bytes[x++] = (char)('0' + (arc4random_uniform(10))));
    //    for (int x = 1; x < 17; bytes[x++] = (char)('1'));
    
    NSData *data = [NSData dataWithBytes:bytes length:strlen(bytes)];
    NSData *data1 = [data SHA256]; // 0x0000600000440e40 <435cd747 69f0b100 6c326a4c be9858b4 5b758250 77d7935a b10632a1 0df5d984>
    NSData *data2 = [data1 SHA256]; // <81a8856c e9d550ec cde94b2b ad489577 585509e4 11cfb96b c54fa02f 571604bf>
    
    char checksum[5];
    char *cstr = [data2 bytes];
    strlcpy(checksum, cstr, 5);
    
    char ret[22];
    sprintf(ret, "%s%s", bytes, checksum);
    
    NSData *retdata = [NSData dataWithBytes:ret length:strlen(ret)];
    NSString *secret = [NSString base58WithData:retdata];
    
    NSLog(@"the secret is %@", secret);
    
    return secret;
}

-(NSString*)deriveKeyPair:(NSString *)secret
{
    NSString *ret;
    
    return ret;
}

@end
