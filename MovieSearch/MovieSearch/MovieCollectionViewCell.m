//
//  MovieCollectionViewCell.m
//  MovieSearch
//
//  Created by Amit Sachdeva on 11/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

-(void)setMovieItem {
    
    
    [self.name setText:@""];
    [self.posterView setImage:[UIImage new]];
}


@end
