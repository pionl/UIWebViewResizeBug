//
//  UIView+iMakers.m
//  Glogster
//
//  Created by Martin Kluska
//  Copyright (c) 2013 iMakers, s.r.o. All rights reserved.
//

#import "UIView+iMakers.h"

@implementation UIView (iMakers)

- (void)localizable {
    
}

#pragma mark Autoresizing

- (id)autoresizingCenter {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin   |
     UIViewAutoresizingFlexibleRightMargin  |
     UIViewAutoresizingFlexibleTopMargin    |
     UIViewAutoresizingFlexibleBottomMargin];
    return self;
}

- (id)autoresizingSizeWithMargins {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin   |
     UIViewAutoresizingFlexibleRightMargin  |
     UIViewAutoresizingFlexibleTopMargin    |
     UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    return self;
}

- (id)autoresizingSize {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    return self;
}

- (id)autoresizeToTopAndRight {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin  |
     UIViewAutoresizingFlexibleTopMargin];
    return self;
}

#pragma mark Center view

- (id)centerToView:(UIView *)view {
    [self setCenter:CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2)];
    return self;
}

- (id)centerToViewWithAutoresizing:(UIView*)view {
    return [[self autoresizingCenter] centerToView:view];
}
- (id)centerToViewWithAutoresizingSize:(UIView*)view {
    return [[self autoresizingSize] centerToView:view];
}
- (id)centerToViewWithAutoresizingSizeWithMargins:(UIView*)view {
    return [[self autoresizingSizeWithMargins] centerToView:view];
}

#pragma mark Position

- (id)topRightToView:(UIView*)view {
    return [self topRightToView:view withOffset:0];
}
- (id)topRightToView:(UIView*)view
          withOffset:(float)offset {
    
    CGRect frame    =   self.frame;
    frame.origin.x  = view.bounds.size.width - frame.size.width - offset;
    frame.origin.y  = offset;
    [self setFrame:frame];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin  |
     UIViewAutoresizingFlexibleTopMargin];
    
    return self;
}

- (void)setBorderColor:(UIColor*)color {
    [[self layer] setBorderColor:[color CGColor]];
}

- (void)setBorderWidth:(NSNumber*)borderWidth {
    [[self layer] setBorderWidth:[borderWidth floatValue]];
}


@end
