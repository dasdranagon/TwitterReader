//
//  TRTwitterTimelineViewModel.h
//  TwitterReader
//
//  Created by Denis Skokov on 16.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRWebClient;

@protocol TRTwitterTimelineViewModel;

@interface TRTwitterTimelineViewModel : NSObject

- (instancetype)initWithWebClient:(TRWebClient *)webClient;
@property (nonatomic, weak) id<TRTwitterTimelineViewModel> delegate;

//          inputs
- (void)activate;
- (void)more;
- (void)update;

//          outputs
@property (nonatomic) BOOL processing;
@property (nonatomic, strong) NSArray *twitts;

@end

@protocol TRTwitterTimelineViewModel <NSObject>
- (void)timelineViewModel:(TRTwitterTimelineViewModel *)viewModel updatedItemAtIndex:(NSInteger)index;
@end