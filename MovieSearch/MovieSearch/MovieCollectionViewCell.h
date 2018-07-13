//
//  MovieCollectionViewCell.h
//  MovieSearch
//
//  Created by Amit Sachdeva on 11/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak) IBOutlet UILabel* name;
@property(nonatomic,weak) IBOutlet UIImageView* posterView;

@end
