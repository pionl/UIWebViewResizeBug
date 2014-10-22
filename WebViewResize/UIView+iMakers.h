//
//  UIView+iMakers.h
//  Glogster
//
//  Created by Martin Kluska
//  Copyright (c) 2013 iMakers, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (iMakers)

- (void)localizable;

#pragma mark Autoresizing

- (id)autoresizingCenter;

- (id)autoresizingSize;
- (id)autoresizingSizeWithMargins;

- (id)autoresizeToTopAndRight;

#pragma mark Center view
- (id)centerToView:(UIView *)view;
- (id)centerToViewWithAutoresizing:(UIView*)view;
- (id)centerToViewWithAutoresizingSize:(UIView*)view;
- (id)centerToViewWithAutoresizingSizeWithMargins:(UIView*)view;

#pragma mark Position

- (id)topRightToView:(UIView*)view;
- (id)topRightToView:(UIView*)view
          withOffset:(float)offset;

#pragma mark - View border

- (void)setBorderColor:(UIColor*)color;
- (void)setBorderWidth:(NSNumber*)borderWidth;

@end
