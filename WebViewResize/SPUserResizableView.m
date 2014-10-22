//
//  SPUserResizableView.m
//  SPUserResizableView
//
//  Created by Stephen Poletto on 12/10/11.
//

#import "SPUserResizableView.h"

/* Let's inset everything that's drawn (the handles and the content view)
   so that users can trigger a resize from a few pixels outside of
   what they actually see as the bounding box. */


static SPUserResizableViewAnchorPoint SPUserResizableViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleLeftAnchorPoint = { 1.0, 0.0, 0.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerLeftAnchorPoint = { 1.0, 0.0, 1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleRightAnchorPoint = { 0.0, 0.0, 0.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerRightAnchorPoint = { 0.0, 0.0, 1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerMiddleAnchorPoint = { 0.0, 0.0, 1.0, 0.0 };

@interface SPGripViewBorderView : UIView
@end

@implementation SPGripViewBorderView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(0.0, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect upperRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerLeft = CGRectMake(0.0, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect upperMiddle = CGRectMake((self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize)/2, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect lowerMiddle = CGRectMake((self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize)/2, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect middleLeft = CGRectMake(0.0, (self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize)/2, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    CGRect middleRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, (self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize)/2, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = { 
        0.4, 0.8, 1.0, 1.0, 
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    for (NSInteger i = 0; i < 8; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

@end

@implementation SPUserResizableView

@synthesize contentView, minWidth, minHeight, preventsPositionOutsideSuperview, delegate;

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    self.minWidth = kSPUserResizableViewDefaultMinWidth;
    self.minHeight = kSPUserResizableViewDefaultMinHeight;
    self.preventsPositionOutsideSuperview = YES;
    _disable    = NO;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    [self addSubview:contentView];
    [contentView setNeedsDisplay];
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [borderView removeFromSuperview];
    [self addSubview:borderView];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [borderView setNeedsDisplay];
}

static CGFloat SPDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

typedef struct CGPointSPUserResizableViewAnchorPointPair {
    CGPoint point;
    SPUserResizableViewAnchorPoint anchorPoint;
} CGPointSPUserResizableViewAnchorPointPair;

- (SPUserResizableViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint {
    
    // (1) Calculate the positions of each of the anchor points.
    CGPointSPUserResizableViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), SPUserResizableViewUpperLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), SPUserResizableViewUpperMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), SPUserResizableViewUpperRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height/2), SPUserResizableViewMiddleRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height), SPUserResizableViewLowerRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerMiddle = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height), SPUserResizableViewLowerMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerLeft = { CGPointMake(0, self.bounds.size.height), SPUserResizableViewLowerLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleLeft = { CGPointMake(0, self.bounds.size.height/2), SPUserResizableViewMiddleLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), SPUserResizableViewNoResizeAnchorPoint };
    
    
    // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
    CGPointSPUserResizableViewAnchorPointPair allPoints[9] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint };
    CGFloat smallestDistance = MAXFLOAT; CGPointSPUserResizableViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 9; i++) {
        CGFloat distance = SPDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) { 
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    // make dragable only small portion of border.
    float check     = (kSPUserResizableViewGlobalInset+5) * 2;
    
    if (touchPoint.x < check+kSPUserResizableViewGlobalInset || touchPoint.x >= (self.bounds.size.width-check) || touchPoint.y < check+kSPUserResizableViewGlobalInset || touchPoint.y >= (self.bounds.size.height-check)) {
        return closestPoint.anchorPoint;
    } else {
        return (SPUserResizableViewAnchorPoint){0,0,0,0};
    }
}

- (BOOL)isResizing {
    return (anchorPoint.adjustsH || anchorPoint.adjustsW || anchorPoint.adjustsX || anchorPoint.adjustsY);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self disable]) {
        return;
    }
    
    // Notify the delegate we've begun our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidBeginEditing:)]) {
        [self.delegate userResizableViewDidBeginEditing:self];
    }
    
    
    
    [borderView setHidden:NO];
    UITouch *touch = [touches anyObject];
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    touchStart = [touch locationInView:self.superview];
    if (![self isResizing]) {
        // When translating, all calculations are done in the view's coordinate space.
        touchStart = [touch locationInView:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self disable]) {
        return;
    }
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self disable]) {
        return;
    }
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
}

- (void)showEditingHandles {
    [borderView setHidden:NO];
}

- (void)hideEditingHandles {
    [borderView setHidden:YES];
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    if ([self disable]) {
        return;
    }
    
    
    CGFloat scaleX      = [[self valueForKeyPath:@"layer.transform.scale.x"] floatValue];
    CGFloat scaleY      = [[self valueForKeyPath:@"layer.transform.scale.y"] floatValue];
    CGFloat rotation    = [[self valueForKeyPath:@"layer.transform.rotation"] floatValue];
    
    // (2) Calculate the deltas using the current anchor point.
    CGFloat deltaW = anchorPoint.adjustsW * (touchStart.x - touchPoint.x) / scaleX;
    CGFloat deltaX = anchorPoint.adjustsX * (-1.0 * deltaW);
    CGFloat deltaH = anchorPoint.adjustsH * (touchPoint.y - touchStart.y) / scaleY;
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    
    CGPoint point;
    if (anchorPoint.adjustsY != 0) {
        if (anchorPoint.adjustsW != 0 && anchorPoint.adjustsX == 0) {
            point   = CGPointMake(0, 1);
        } else {
            point = CGPointMake(1, 1);
        }
    } else if (anchorPoint.adjustsX != 0) {
        point   = CGPointMake(1, 0);
    } else {
        point   = CGPointMake(0, 0);
    }
    
    [self setAnchorPoint:point forView:self];
    
    // restore to normal cords
    [self setTransform:CGAffineTransformIdentity];
    
    //NSLog(@"After identity Frame %@",NSStringFromCGRect(self.frame));
    
    CGRect frame    = self.frame;
        
    // (3) Calculate the new frame.
    CGFloat newX = frame.origin.x + deltaX;
    CGFloat newY = frame.origin.y + deltaY;
    CGFloat newWidth = frame.size.width + deltaW;
    CGFloat newHeight = frame.size.height + deltaH;
    
    // (4) If the new frame is too small, cancel the changes.
    if (newWidth < self.minWidth) {
        newWidth = frame.size.width;
        newX = frame.origin.x;
    }
    
    if (newHeight < self.minHeight) {
        newHeight = frame.size.height;
        newY        = frame.origin.y;
    }
    
    
    self.frame  = CGRectMake(newX, newY, newWidth, newHeight);
    //NSLog(@"New frame %@",NSStringFromCGRect(self.frame));
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(userResizableViewNewRealFrame:)]) {
        [[self delegate] userResizableViewNewRealFrame:self];
    }
    
    CGAffineTransform transform     = CGAffineTransformMakeRotation(rotation);
    
    [self setTransform:CGAffineTransformScale(transform, scaleX, scaleY)];
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(userResizableViewResized:)]) {
        [[self delegate] userResizableViewResized:self];
    }
    
    touchStart  = touchPoint;
    
}

-(void)setAnchorPoint:(CGPoint)anchor forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchor.x,
                                   view.bounds.size.height * anchor.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchor;
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self disable] || [touches count] > 1) {
        return;
    }
    if ([self isResizing]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
    } else {
        //[self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
    }
}

- (void)dealloc {
    [contentView removeFromSuperview];
    [borderView release];
    [super dealloc];
}

@end
