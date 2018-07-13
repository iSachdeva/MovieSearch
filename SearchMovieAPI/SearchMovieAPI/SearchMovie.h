//
//  SearchMovieAPI.h
//  MovieSearch
//
//  Created by Amit Sachdeva on 11/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchMovie : NSObject

typedef void (^SearchMovieCompletionBlock) (BOOL isSuccess,NSError* error,NSDictionary* response);

-(void)searchMovieWithTitle:(NSString*)title inYear:(NSString*)year andCompletionHandler:(SearchMovieCompletionBlock) completionHandler;
-(void)updateAPIKey;

@end
