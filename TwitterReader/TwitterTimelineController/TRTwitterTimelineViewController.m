//
//  TRTwitterTimelineViewController.m
//  TwitterReader
//
//  Created by Denis Skokov on 16.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRTwitterTimelineViewController.h"
#import "TRTwitterTimelineViewModel.h"
#import "TRTimelineRepresentation.h"
#import "TRWebClient.h"

#import "TRGridViewController.h"
#import "TRListViewController.h"

@interface TRTwitterTimelineViewController ()<TRTimelineRepresentationDelegate, TRTwitterTimelineViewModel>{
    TRTwitterTimelineViewModel *_viewModel;
    __weak IBOutlet UISegmentedControl *_representationSwitcher;
    __weak IBOutlet UIScrollView *_containerView;
    NSArray *_representations;
}
@end

@implementation TRTwitterTimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewModel = [[TRTwitterTimelineViewModel alloc] initWithWebClient:[TRWebClient sharedInstance]];
        _viewModel.delegate = self;
        
        [_viewModel addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(twitts))
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        [_viewModel addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(processing))
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        
        TRListViewController *list = [TRListViewController new];
        list.delegate = self;
        
        TRGridViewController *grid = [TRGridViewController new];
        grid.delegate = self;
        
        _representations = @[list, grid];
    }
    
    return self;
}

- (void)dealloc
{
    [_viewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(twitts))];
    [_viewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(processing))];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_representationSwitcher addTarget:self action:@selector(changePresenter:) forControlEvents: UIControlEventValueChanged];
    [self addRepresentationsToContainer];
    [_viewModel activate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutRepresentations];
}

- (void)changePresenter:(UISegmentedControl *)segmented
{
    CGRect frm = _containerView.frame;
    frm.origin.x = frm.size.width*segmented.selectedSegmentIndex;
    [_containerView scrollRectToVisible:frm animated:YES];
}

- (void)addRepresentationsToContainer
{
    __weak TRTwitterTimelineViewController *weakSelf = self;
    [_representations enumerateObjectsUsingBlock:^(id<TRTimelineRepresentation> representation, NSUInteger idx, BOOL *stop) {
        __strong TRTwitterTimelineViewController *strongSelf = weakSelf;
        UIView *view = [representation view];
        [strongSelf->_containerView addSubview:view];
    }];
}

- (void)layoutRepresentations
{
    CGRect containerFrm = _containerView.bounds;
    [_containerView setContentSize:CGSizeMake(containerFrm.size.width*_representations.count, containerFrm.size.height)];
    [_representations enumerateObjectsUsingBlock:^(id<TRTimelineRepresentation> representation, NSUInteger idx, BOOL *stop) {
        UIView *view = [representation view];
        CGRect frm = containerFrm;
        frm.origin.x = idx*containerFrm.size.width;
        [view setFrame:frm];
    }];
}

#pragma mark -- KVO


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(twitts))]) {
        [self updateRepresentations];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(processing))]) {
        [self changeRepresentationsProgressing];
    }
}

- (void)updateRepresentations
{
    [_representations enumerateObjectsUsingBlock:^(id<TRTimelineRepresentation> representation, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [representation updateList];
        });
    }];

}
- (void)changeRepresentationsProgressing
{
    [_representations enumerateObjectsUsingBlock:^(id<TRTimelineRepresentation> representation, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [representation updateProgressing:_viewModel.processing];
        });
    }];
}

#pragma mark - TRTimelineRepresentationDelegate

- (NSInteger)twittsCount
{
    return [_viewModel.twitts count];
}
- (TRTwitt *)twittAtIndex:(NSInteger)idx
{
    return _viewModel.twitts[idx];
}

- (void)representation:(id<TRTimelineRepresentation>)representation signal:(TRTimelineRepresentationSignal)signal
{
    switch (signal) {
        case TRTimelineRepresentationSignalUpdate:
            [_viewModel update];
            break;
            
        case TRTimelineRepresentationSignalLoadMore:
            [_viewModel more];
            break;
            
        default:
            break;
    }
}

#pragma mark - TRTwitterTimelineViewModel

- (void)timelineViewModel:(TRTwitterTimelineViewModel *)viewModel updatedItemAtIndex:(NSInteger)index
{
    [_representations enumerateObjectsUsingBlock:^(id<TRTimelineRepresentation> representation, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [representation updateItemAtIndex:index];
        });
    }];
}

@end
