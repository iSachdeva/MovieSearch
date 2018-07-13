//
//  Encrypt.m
//  Secure
//
//  Created by Amit Sachdeva on 13/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "Encrypt.h"
#import "SecureManager.h"

@implementation Encrypt

+(void)saveKey:(NSString*)key {
    NSString* privateKey =@"com.idevamit.app.mykey"; //this need to get either from API and save in keychain as secured key and then use. for now , i am just putting as hardcoded
    [Encrypt createKeyPair:privateKey];
    NSString* encryptedStr = [Encrypt encrypt:key withSecretCode:privateKey];
    [SecureManager storeKeys:encryptedStr forService:@"testService" account:@"myAccount" error:nil];
}

+(NSString*)getAPIKey{
    NSString* keys = [SecureManager getKeysForService:@"testService" account:@"myAccount"];
    NSString* decryptedString = [Encrypt decrypt:keys withSecretCode:@"com.idevamit.app.mykey"];
    return decryptedString;
}

+(NSDictionary*)getAttributes:(NSString*)secretCode  {
    
    NSData* tag = [secretCode dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* attributes =
    @{ (id)kSecAttrKeyType:      (id)kSecAttrKeyTypeRSA,
       (id)kSecAttrKeySizeInBits:    @2048,
       (id)kSecPrivateKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @YES,
              (id)kSecAttrApplicationTag: tag,
              },
       };
    
    return attributes;
}

+(Boolean) createKeyPair:(NSString *) secretCode {
    
    NSDictionary* attributes = [Encrypt getAttributes:secretCode];
    SecKeyRef privateKey = NULL;
    SecKeyRef publicKey = NULL;
    OSStatus status = SecKeyGeneratePair( (__bridge CFDictionaryRef)attributes, &publicKey, &privateKey);
    if (status == errSecSuccess) {
        NSData* tag = [secretCode dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* addquery = @{ (id)kSecValueRef: (__bridge id)privateKey,
                                    (id)kSecClass: (id)kSecClassKey,
                                    (id)kSecAttrApplicationTag: tag,
                                    };
        
        OSStatus addStatus = SecItemAdd((__bridge CFDictionaryRef)addquery, NULL);
        if (addStatus != errSecSuccess) {
            NSLog(@"Failed to save");
            return false;
        } else {
            NSLog(@"Saved successfully");
            return true;
        }
    }
    return false;
}

+(SecKeyRef) getKeychainKeyFor:(NSString*) secretCode {
    
    NSData* tag = [secretCode dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *getquery = @{ (id)kSecClass: (id)kSecClassKey,
                                (id)kSecAttrApplicationTag: tag,
                                (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                                (id)kSecReturnRef: @YES,
                                };

    SecKeyRef key = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery,
                                          (CFTypeRef *)&key);
    if (status != errSecSuccess) {
        NSLog(@"Failed to get key");
    } else {
        NSLog(@"Got the key");
    }
    return key;
}

+(NSString*) encrypt:(NSString*)key withSecretCode:(NSString*)secretCode {
    
    NSDictionary* attributes = [Encrypt getAttributes:secretCode];
    
    CFErrorRef error = NULL;
    //SecKeyRef privateKey = NULL;
    SecKeyRef privateKey = [Encrypt getKeychainKeyFor:secretCode];
    //OSStatus status = SecKeyGeneratePair( (__bridge CFDictionaryRef)attributes, &publicKey, &privateKey);
    
    /*SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes,
                                                 &error);*/
    if (!privateKey) {
        NSError *err = CFBridgingRelease(error);
        return nil; //failed
    }
    
    SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
    
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA512;
    BOOL canEncrypt = SecKeyIsAlgorithmSupported(publicKey,
                                                 kSecKeyOperationTypeEncrypt,
                                                 algorithm);
    
    NSData *plainText = [key dataUsingEncoding:NSUTF8StringEncoding];
    canEncrypt &= ([plainText length] < (SecKeyGetBlockSize(publicKey)-130));
    
    NSData* encryptedData = nil;
    if (canEncrypt) {
        CFErrorRef error = NULL;
        encryptedData = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(publicKey,
                                                                          algorithm,
                                                                          (__bridge CFDataRef)plainText,
                                                                          &error));
        if (!encryptedData) {
            NSError *err = CFBridgingRelease(error);
            return nil;
        }
    }
    
    if (publicKey)  { CFRelease(publicKey);  }
    if (privateKey) { CFRelease(privateKey); }
    
    NSString* finalEncryptedString = [encryptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];//[encryptedData ];
    
    return finalEncryptedString;
}

+(NSString*) decrypt:(NSString*)encryptedString withSecretCode:(NSString*)secretCode {
    
    NSDictionary* attributes = [Encrypt getAttributes:secretCode];
    
    CFErrorRef error = NULL;
    //SecKeyRef privateKey = NULL;
    //SecKeyRef publicKey = NULL;
    //OSStatus status = SecKeyGeneratePair( (__bridge CFDictionaryRef)attributes, &publicKey, &privateKey);
    SecKeyRef privateKey = [Encrypt getKeychainKeyFor:secretCode];
    
    //SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes,&error);
    if (!privateKey) {
        NSError *err = CFBridgingRelease(error);
        return nil; //failed
    }
    
    //NSDataBase64Encoding64CharacterLineLength
    
    NSData* cipherTextData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);

    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA512;

    BOOL canDecrypt = SecKeyIsAlgorithmSupported(privateKey,
                                                 kSecKeyOperationTypeDecrypt,
                                                 algorithm);
    canDecrypt &= ([cipherTextData length] == SecKeyGetBlockSize(privateKey));
    
    NSData* clearText = nil;
    if (canDecrypt) {
        CFErrorRef error = NULL;
        clearText = (NSData*)CFBridgingRelease(SecKeyCreateDecryptedData(privateKey,
                                                                         algorithm,
                                                                         (__bridge CFDataRef)cipherTextData,
                                                                         &error));
        if (!clearText) {
            NSError *err = CFBridgingRelease(error);  // ARC takes ownership
            NSLog(@"Cannot decrypt:  %@",err);
            return nil;
        } else {
            NSLog(@"SUCCESS decrypt");
            NSString* finalStr = [[NSString alloc] initWithData:clearText encoding:NSUTF8StringEncoding];
            NSLog(@"Str: %@",finalStr);
            return finalStr;
        }
    } else {
        NSLog(@"Cannot decrypt");
        return nil;
    }
    return nil;
}

@end
