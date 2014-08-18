//
//  TRGridViewController.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTimelineRepresentation.h"

@interface TRGridViewController : UIViewController<TRTimelineRepresentation>
@property (nonatomic, weak) id<TRTimelineRepresentationDelegate> delegate;
@end
