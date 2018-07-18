//
//  SearchMovie.m
//  MovieSearch
//
//  Created by Amit Sachdeva on 11/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "SearchMovie.h"
#import "Encrypt.h"
#import "MovieStruct.h"
#import "Sorter.h"

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
    
    __typeof(self) __weak weakSelf = self;
    
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
                                                            NSMutableDictionary* responseDict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                                            BOOL isSuccess = error ? NO : YES;
                                                            NSMutableDictionary *mutableResponse = [NSMutableDictionary new];
                                                            if(isSuccess) {
                                                                [mutableResponse setDictionary:responseDict];
                                                                NSArray* sorted = [[NSArray alloc]initWithArray:[weakSelf sortMovies:responseDict]];
                                                                [mutableResponse setObject:sorted forKey:@"results"];
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    completionHandler(isSuccess,error,mutableResponse);
                                                                });
                                                            } else {
                                                                completionHandler(isSuccess,error,mutableResponse);
                                                            }
                                                        } else {
                                                            // populate the error object with the details
                                                            NSError* error = [NSError errorWithDomain:@"custom" code:111 userInfo:@{NSLocalizedDescriptionKey:@"Oops Something went wrong. Please check your API key"}];
                                                            completionHandler(NO,error,nil);
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}

-(NSMutableArray*)sortMovies:(NSDictionary*)response{
    
    NSArray* movies = [response objectForKey:@"results"];
    if(movies == nil || [movies isKindOfClass:[NSNull class]] || movies.count == 0) {
        NSLog(@"MOVIES IS NULL");
        return [NSMutableArray new];
    }
    
    int length = (int)movies.count;
    struct MovieStruct cArray[length];
    
    for (int i = 0; i < length; i++) {
        NSDictionary *dict = [movies objectAtIndex:i];
        NSString *title = [dict objectForKey:@"title"];
        NSString *imageUrl = [dict objectForKey:@"poster_path"];
        if(imageUrl == nil || [imageUrl isKindOfClass:[NSNull class]]) {
            imageUrl = @"";
        }
        if(title == nil || [title isKindOfClass:[NSNull class]]) {
            title = @"";
        }
        int rating = [[dict objectForKey:@"vote_count"] intValue];
        struct MovieStruct *newStruct = MovieStructInit([title UTF8String], (int)title.length, rating,[imageUrl UTF8String],(int)imageUrl.length);
        cArray[i] = *newStruct;
    }
    
    struct MovieStruct *newArray = SortElements(cArray, length);
    
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        struct MovieStruct *aMovie = &newArray[i];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSString stringWithFormat:@"%s", aMovie->title] forKey:@"title"];
        [dict setObject:[NSString stringWithFormat:@"%s", aMovie->imageUrl] forKey:@"posterImageUrl"];
        [dict setObject:[NSNumber numberWithInt:aMovie->rating] forKey:@"vote_count"];
        if(mutArray.count >10) {
            break;
        } else {
            [mutArray addObject:dict];
        }
    }
    
    return mutArray;
}


@end
