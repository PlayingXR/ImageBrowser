//
//  WXHImageBrowserCell.h
//  Test
//
//  Created by Jerry on 2017/5/6.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXHImageBrowserCell;
@class WXHImageBrowser;

static NSTimeInterval const animationDuration = 0.2;
typedef void (^CompletionBlock)(BOOL finished);

@protocol WXHImageBrowserCellDelegate <NSObject>

- (CGRect)appearRectOfBrowserCell:(WXHImageBrowserCell *)cell;
- (CGRect)disappearRectOfBrowserCell:(WXHImageBrowserCell *)cell;

@optional
- (void)browserCell:(WXHImageBrowserCell *)cell zoomScale:(CGFloat)scale;
- (void)browserCell:(WXHImageBrowserCell *)cell dissmiss:(BOOL)finished;
@end

@interface WXHImageBrowserCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat maxZoomScale;
@property (nonatomic, assign) CGFloat minZoomScale;

@property (nonatomic, assign) CGFloat willDismissScale;
@property (nonatomic, assign) CGFloat dismissZoomScale;
@property (nonatomic, assign) CGFloat dismissPanLength;

@property (nonatomic, assign, readonly) CGFloat currentScale;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTapGesture;

@property (nonatomic, assign) id<WXHImageBrowserCellDelegate> delegate;
@property (nonatomic, weak) WXHImageBrowser *imageBrowser;

- (void)resetState;
- (void)showWithAnimation;
- (void)dismissWithAnimation:(BOOL)finished;

@end
