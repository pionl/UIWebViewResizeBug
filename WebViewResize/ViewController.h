//
//  ViewController.h
//  WebViewResize
//
//  Created by Martin Kluska on 22.10.14.
//  Copyright (c) 2014 iMakers, s.r.o,. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPUserResizableView;

@interface ViewController : UIViewController <UIWebViewDelegate>


@property (nonatomic, strong) SPUserResizableView *viewToResize;
@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) UIWebView *textView;

@end

