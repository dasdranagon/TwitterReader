//
//  TRGridViewController.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRGridViewController.h"
#import "TRGridLoadMoreFooter.h"
#import "TRGridCell.h"

static NSString * const kTwittGridCellReuseIdentifier = @"kTwittGridCellReuseIdentifier";
static NSString * const kTwittGridFooterReuseIdentifier = @"kTwittGridFooterReuseIdentifier";

@interface TRGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_collectionView;
    UIRefreshControl *_refreshControl;
    UIActivityIndicatorView *_loadMoreProcessing;
}

@end

@implementation TRGridViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [_collectionView registerNib:[UINib nibWithNibName:@"TRGridCell" bundle:nil] forCellWithReuseIdentifier:kTwittGridCellReuseIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:@"TRGridLoadMoreFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kTwittGridFooterReuseIdentifier];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_collectionView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)pullToRefresh
{
    [_delegate representation:self signal:TRTimelineRepresentationSignalUpdate];
}

- (void)updateList
{
    [_collectionView reloadData];
}

- (void)updateItemAtIndex:(NSInteger)idx
{
    NSArray *visible = [_collectionView indexPathsForVisibleItems];
    [visible enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger i, BOOL *stop) {
        if (idx == i) {
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
            *stop = YES;
        }
    }];
}

- (void)updateProgressing:(BOOL)progress
{
    if (progress) {
        [_refreshControl beginRefreshing];
        [_loadMoreProcessing setHidden:NO];
        [_loadMoreProcessing startAnimating];
    }
    else {
        [_refreshControl endRefreshing];
        [_loadMoreProcessing setHidden:YES];
        [_loadMoreProcessing stopAnimating];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_delegate twittsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TRGridCell *cell = (TRGridCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:kTwittGridCellReuseIdentifier forIndexPath:indexPath];
    [cell setTwittInfo:[_delegate twittAtIndex:indexPath.row]];

    cell.tag = indexPath.row;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TRGridLoadMoreFooter *footer = (TRGridLoadMoreFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                              withReuseIdentifier:kTwittGridFooterReuseIdentifier
                                                                                                     forIndexPath:indexPath];
    _loadMoreProcessing = footer.activityIndicator;
    [_delegate representation:self signal:TRTimelineRepresentationSignalLoadMore];
    return footer;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TRGridCell contentSizeForTwittInfo:[_delegate twittAtIndex:indexPath.row]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(300, 50);
}
@end
