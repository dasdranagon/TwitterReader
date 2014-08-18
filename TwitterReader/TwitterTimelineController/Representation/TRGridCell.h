//
//  TRGridCell.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRTwitt;

@interface TRGridCell : UICollectionViewCell

- (void)setTwittInfo:(TRTwitt *)twitt;
+ (CGSize)contentSizeForTwittInfo:(TRTwitt *)twitt;

@end
