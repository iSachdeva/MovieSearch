//
//  SearchMovieViewController.m
//  MovieSearch
//
//  Created by Amit Sachdeva on 8/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#import "SearchMovieViewController.h"
#import "MovieCollectionViewCell.h"
#import "UIImageView+DataTask.h"
#import <SearchMovieAPI/SearchMovieAPI.h>

@interface SearchMovieViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,UISearchBarDelegate> {
}

@property (nonatomic,weak) IBOutlet UICollectionView* moviesCollectionView;
@property (nonatomic,weak) IBOutlet UISearchBar* movieSearchBar;
@property (nonatomic,retain)  UIActivityIndicatorView* activityIndicator;

@property (nonatomic,retain) NSMutableArray* moviesList;
@property (nonatomic,retain) SearchMovie* searchAPI;

@end

@implementation SearchMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moviesList = [NSMutableArray new];
    self.searchAPI = [[SearchMovie alloc] init];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Key" style:UIBarButtonItemStylePlain target:self  action:@selector(addButtomTapped:)];
    
    self.navigationItem.leftBarButtonItem = addButton;
    
    //Looks for single or multiple taps.
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
   
}

-(void)addButtomTapped:(id)button {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Movie Search" message:@"Please input your API key" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Add your API key";
    }];
    
    __typeof(self) __weak weakSelf = self;
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString* inputText = [[alertController textFields][0] text];
        if(inputText!=nil && inputText.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [Encrypt saveKey:inputText];
               [weakSelf.searchAPI updateAPIKey];
            });
        }
    }];
    
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tapDetected {
    [self.view endEditing:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search has clicked %@",searchBar.text);
    [self.view endEditing:true];
    [self search];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length < 1) {
        [self.moviesList removeAllObjects];
        [self.moviesCollectionView reloadData];
    }
}

- (void)search {
    
    if(self.movieSearchBar.text.length < 1) {return;}
    
    [self.activityIndicator startAnimating];
    [self.searchAPI searchMovieWithTitle:self.movieSearchBar.text inYear:@"2017" andCompletionHandler:^(BOOL isSuccess,NSError* error,NSDictionary* response) {
    
        if(isSuccess == YES) {
            [self.moviesList removeAllObjects];
            [self.moviesList addObjectsFromArray:[response objectForKey:@"results"]];
            [self.moviesCollectionView reloadData];
        } else {
            NSString* errorMessage = [error.userInfo valueForKey:@"NSLocalizedDescription"];
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Movie Search"
                                                                           message:errorMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }

        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - UICollectionView Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moviesList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionView_ID" forIndexPath:indexPath];
    NSString* title = [self.moviesList[indexPath.row] objectForKey:@"title"];
    NSString* imagePath = [self.moviesList[indexPath.row] objectForKey:@"posterImageUrl"];
    [cell.name setText:title];
    NSString* imageURL = [NSString  stringWithFormat:@"%@w500%@",@"https://image.tmdb.org/t/p/",imagePath];
    [cell.posterView setImageWithURL:imageURL];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat itemsPerRow = 2;
    UIEdgeInsets sectionInsets = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
    
    CGFloat paddingSpace = sectionInsets.left * (itemsPerRow + 1);
    CGFloat availableWidth = self.view.frame.size.width - paddingSpace;
    CGFloat widthPerItem = availableWidth / itemsPerRow;
    
    return CGSizeMake(widthPerItem,widthPerItem * 1.50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0).left;
}


@end
