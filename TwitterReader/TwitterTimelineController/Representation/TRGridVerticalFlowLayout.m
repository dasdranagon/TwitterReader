//
//  TRGridVerticalFlowLayout.m
//  TwitterReader
//
//  Created by Denis Skokov on 18.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRGridVerticalFlowLayout.h"

static CGFloat const kVerticalInset = 8;

@implementation TRGridVerticalFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesList = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesList) {
        if (attributes.representedElementKind == nil) {
            attributes.frame = [[self layoutAttributesForItemAtIndexPath:attributes.indexPath] frame];
        }
    }
    return attributesList;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.row < 2) {
        CGRect frm = attributes.frame;
        frm.origin.y = kVerticalInset;
        attributes.frame = frm;
        return attributes;
    }
    
    NSIndexPath *prevIndexPath = [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
    
    CGRect prevFrm = [[self layoutAttributesForItemAtIndexPath:prevIndexPath] frame];
    CGFloat y = prevFrm.origin.y + prevFrm.size.height + kVerticalInset;
    CGRect frm = attributes.frame;
    
    if (frm.origin.y <= y) {
        return attributes;
    }
    
    frm.origin.y = y;
    attributes.frame = frm;
    
    return attributes;
}

@end
