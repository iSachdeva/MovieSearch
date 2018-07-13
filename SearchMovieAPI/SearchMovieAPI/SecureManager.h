//
//  SecureManager.h
//  Secure
//
//  Created by Amit  on 13/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef enum {
    
    SecErrorNone = noErr,
    
    SecErrorBadArguments = -1001,
    
    SecErrorNoPassword = -1002,
    
    SecErrorInvalidParameter = errSecParam,
    
    SecErrorFailedToAllocated = errSecAllocate,
    
    SecErrorNotAvailable = errSecNotAvailable,
    
    SecErrorAuthorizationFailed = errSecAuthFailed,
    
    SecErrorDuplicatedItem = errSecDuplicateItem,
    
    SecErrorNotFound = errSecItemNotFound,
    
    SecErrorInteractionNotAllowed = errSecInteractionNotAllowed,
    
    SecErrorFailedToDecode = errSecDecode
} SecErrorCode;

@interface SecureManager : NSObject {
    
}

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

+ (BOOL)storeKeys:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

+ (NSString *)getKeysForService:(NSString *)service account:(NSString *)account;

@end
