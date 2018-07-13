//
//  Encrypt.h
//  Secure
//
//  Created by Amit Sachdeva on 13/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@interface Encrypt : NSObject

+(NSString*)getAPIKey;
+(void)saveKey:(NSString*)key;

@end
