//
//  ViewController.m
//  WebViewResize
//
//  Created by Martin Kluska on 22.10.14.
//  Copyright (c) 2014 iMakers, s.r.o,. All rights reserved.
//

#import "ViewController.h"
#import "UIView+iMakers.h"
#import "SPUserResizableView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect textViewFrame    = CGRectMake(0, 0, 500, 500);
    
    _viewToResize    = [[SPUserResizableView alloc] initWithFrame:textViewFrame];
    
    [[self viewToResize] showEditingHandles];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup text view (webview for html)
    _textView       = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, textViewFrame.size.width, textViewFrame.size.height)];
    
    // remove the shadow
    [[self.textView.scrollView subviews] enumerateObjectsUsingBlock:^(UIView* shadowView, NSUInteger idx, BOOL *stop) {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }];
    
    // ensure that textview is Autoresize (dont do anything in this case)
    //[[self.textView scrollView] autoresizingSize];
    
    [self.textView autoresizingSize];
    
    [[self.textView scrollView] setBounces:NO];
    
    [self.textView setUserInteractionEnabled:NO];
    [self.textView setDelegate:self];
    [self.textView setOpaque:NO];
    [self.textView setScalesPageToFit:YES];
    
    [[self textView] setBackgroundColor:[UIColor clearColor]];
    
    // fixed clipping on iOS7 on IOS7 SDK
    _textContainer         = [[UIView alloc] initWithFrame:textViewFrame];
    [[self textContainer] addSubview:self.textView];
    
    // set the content view
    [[self viewToResize] setContentView:[self textContainer]];
    
    // autoresizing
    [[self textContainer] autoresizingSize];
    
    // addo to view
    [[self view] addSubview:[self viewToResize]];
    
    [[self viewToResize] setBackgroundColor:[UIColor blackColor]];
    
    // identifiy the web view
    [[self textView] setBackgroundColor:[UIColor redColor]];
    [[self textView] loadHTMLString:@"<html style='display:block;'><head><meta name='viewport' content='width=device-width; minimum-scale=1.0; maximum-scale=1.0; user-scalable=no;'><body style='background: yellow;'>asdj kasjkd jasdj kasjlkd jaslkjd lasjlkd jaskldj lkasjdkl jaskljd kljaslkd jklsajd kljaskldj klsajdlk jsakljd klsajkd jlskajd ljsakl djklasj lkjaskljd lkasjd kljaskjd lksaj dkljakd jlkasj dkasj dlkjaslkd jklasj lasd</body></html>" baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
