//
//  UIImageViewDataTask.m
//  MovieSearch
//
//  Created by Amit Sachdeva on 12/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "UIImageView+DataTask.h"
#import "UIImageView+DataTask.h"
#import <objc/runtime.h>

static char SessionDataTaskKey;

@implementation UIImageView (DataTask)

-(void)setDataTask:(NSURLSessionDataTask*)dataTask
{
    objc_setAssociatedObject(self, &SessionDataTaskKey, dataTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSURLSessionDataTask*)dataTask
{
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, &SessionDataTaskKey);
}

-(void)setImageWithURL:(NSString*)imagePath
{
    NSURL *imageURL = [[NSURL alloc] initWithString:imagePath];
    
    NSURLSession *session = [NSURLSession sharedSession];

    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    if (imageURL) {
        __weak typeof(self) weakSelf = self;
        self.dataTask = [session dataTaskWithURL:imageURL
                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                   __strong __typeof(weakSelf) strongSelf = weakSelf;
                                   if (error) {
                                       //NSLog(@"ERROR: %@", error);
                                   }
                                   else {
                                       NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                                       if (200 == httpResponse.statusCode) {
                                           UIImage * image = [UIImage imageWithData:data];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               strongSelf.image = image;
                                           });
                                       } else {
                                           //NSLog(@"Couldn't load image at URL: %@", imageURL);
                                           //NSLog(@"HTTP %ld", (long)httpResponse.statusCode);
                                       }
                                   }
                               }];
        [self.dataTask resume];
    }
    return;
}

@end
