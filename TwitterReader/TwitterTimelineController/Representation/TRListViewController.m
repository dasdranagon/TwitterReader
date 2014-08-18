//
//  TRListViewController.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRListViewController.h"
#import "TRListCell.h"

static NSString * const kTwittCellReuseIdentifier = @"kTwittCellReuseIdentifier";

@interface TRListViewController ()<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIActivityIndicatorView *_loadMoreProcessing;
    UIRefreshControl *_refreshControl;
    NSMutableIndexSet *_visibleItems;
}

@end

@implementation TRListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _visibleItems = [[NSMutableIndexSet alloc] init];
    [_tableView registerNib:[UINib nibWithNibName:@"TRListCell" bundle:nil] forCellReuseIdentifier:kTwittCellReuseIdentifier];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    
    
    [_loadMoreProcessing setHidden:YES];
    
}

- (void)pullToRefresh
{
    
    [_delegate representation:self signal:TRTimelineRepresentationSignalLoadMore];
}

- (void)updateList
{
    [_tableView reloadData];
}

- (void)updateItemAtIndex:(NSInteger)idx
{
    if ([_visibleItems containsIndex:idx]) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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

#pragma mark -- UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRListCell *cell = (TRListCell *)[tableView dequeueReusableCellWithIdentifier:kTwittCellReuseIdentifier forIndexPath:indexPath];
    [cell setTwittInfo:[_delegate twittAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate twittsCount];
}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TRTwitt *twitt = [_delegate twittAtIndex:indexPath.row];
    return [TRListCell contentSizeForTwittInfo:twitt].height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_visibleItems addIndex:indexPath.row];
    if (indexPath.row == [_delegate twittsCount]-1) {
        [_delegate representation:self signal:TRTimelineRepresentationSignalUpdate];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_visibleItems removeIndex:indexPath.row];
}

@end
