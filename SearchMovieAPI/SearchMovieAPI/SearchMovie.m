//
//  SearchMovie.m
//  MovieSearch
//
//  Created by Amit Sachdeva on 11/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "SearchMovie.h"
#import "Encrypt.h"

static NSString * const BASE_URL = @"https://api.themoviedb.org/3/";
static NSString * const SEARCH_URL = @"search/movie";

@implementation SearchMovie

 NSString* apiKey = nil;

-(id) init {
    self = [super init];
    if (self) {
        apiKey = [Encrypt getAPIKey];
    }
    return(self);
}

-(void)updateAPIKey{
    apiKey = nil;
    apiKey = [Encrypt getAPIKey];
}

-(void)searchMovieWithTitle:(NSString*)title inYear:(NSString*)year andCompletionHandler:(SearchMovieCompletionBlock) completionHandler {
    
    
    NSString* urlWithQueryParams = [NSString stringWithFormat:@"%@%@?api_key=%@&year=%@&query=%@",BASE_URL,SEARCH_URL,apiKey,year,title];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlWithQueryParams]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionHandler(NO,error,nil);
                                                        });
                                                    } else {
                                                        NSError* error = nil;
                                                        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
                                                        if(httpResponse.statusCode == 200) {
                                                            NSDictionary* responseDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                BOOL isSuccess = error ? NO : YES;
                                                                completionHandler(isSuccess,error,responseDict);
                                                            });
                                                        } else {
                                                            // populate the error object with the details
                                                            NSError* error = [NSError errorWithDomain:@"custom" code:111 userInfo:@{NSLocalizedDescriptionKey:@"Oops Something went wrong. Please check your API key"}];
                                                            completionHandler(NO,error,nil);
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}


@end
