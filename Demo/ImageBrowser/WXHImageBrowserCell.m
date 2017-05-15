//
//  WXHImageBrowserCell.m
//  Test
//
//  Created by Jerry on 2017/5/6.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import "WXHImageBrowserCell.h"
#import "WXHImageBrowser.h"

@interface WXHImageBrowserCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGPoint beginPinchCenter;
@property (nonatomic, assign) CGPoint movePinchCenter;

@property (nonatomic, assign) CGFloat panScale;
@property (nonatomic, assign) CGRect panFrame;

@property (nonatomic, assign) BOOL isPanGesture;
@property (nonatomic, assign) BOOL isWillDismiss;


@end
@implementation WXHImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.maxZoomScale = 3.0;
        self.minZoomScale = 1.0;
        
        self.dismissPanLength = 100.0;
        self.dismissZoomScale = 0.5;
        self.willDismissScale = 0.7;
        
        _currentScale = self.minZoomScale;
        
        //设置ScrollView 利用ScrollView完成图片的放大功能
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    [self resetState];
}

#pragma mark - Public
- (void)resetState
{
    _currentScale = self.minZoomScale;
    CGSize size = [self imageSizeForScale:self.currentScale];
    CGRect rect = [self zoomImageForScale:_currentScale point:CGPointMake(size.width/2.0, size.height/2.0) centering:YES];
    rect.origin.x = rect.origin.x < 0 ? 0 : rect.origin.x;
    rect.origin.y = rect.origin.y < 0 ? 0 : rect.origin.y;
    self.imageView.frame = rect;
    [self adjustScrollFrame];
}
- (void)showWithAnimation
{
    [self resetState];
    CGRect imageFrame = self.imageView.frame;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(appearRectOfBrowserCell:)]) {
        self.imageView.frame = [self.delegate appearRectOfBrowserCell:self];
    }
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.imageView.frame = imageFrame;
                     }];
}
- (void)dismissWithAnimation:(BOOL)finished
{
    if (finished) {
        CGRect imageFrame = self.imageView.frame;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(disappearRectOfBrowserCell:)]) {
            imageFrame = [self.delegate disappearRectOfBrowserCell:self];
        }
        
        if (!self.isPanGesture) {
            imageFrame.origin.x += self.scrollView.contentOffset.x;
            imageFrame.origin.y += self.scrollView.contentOffset.y;
        }
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.imageView.frame = imageFrame;
                         }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserCell:dissmiss:)]) {
        [self.delegate browserCell:self dissmiss:finished];
    }
}


#pragma mark - 手势
- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture
{
    if (self.currentScale != 1.0f) {return;}
    
    if (panGesture.state == UIGestureRecognizerStateEnded ||
        panGesture.state == UIGestureRecognizerStateCancelled) {
        if (self.isPanGesture) {
            //如果下拉的缩放大小小于了消失的倍数，且继续下拉，就做消失
            if (self.panScale < self.willDismissScale && self.isWillDismiss) {
                [self dismissWithAnimation:YES];
            } else {
                [self dismissWithAnimation:NO];
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     self.imageView.frame = self.panFrame;
                                 }];
            }
        }
        self.isPanGesture = NO;
        self.imageBrowser.collectionView.scrollEnabled = YES;
        self.scrollView.panGestureRecognizer.enabled = YES;
        self.scrollView.pinchGestureRecognizer.enabled = YES;
    } if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.isPanGesture = NO;
        self.panScale = self.currentScale;
        
        CGPoint point = [panGesture velocityInView:panGesture.view];//在pan手势响应开始时，利用下拉的速度来判断是否是下拉
        if ((panGesture.numberOfTouches < 2) && (point.y > 0) && (self.scrollView.contentOffset.y <= 2)) {
            
            self.imageBrowser.collectionView.scrollEnabled = NO;
            self.scrollView.pinchGestureRecognizer.enabled = NO;
            
            self.panFrame = self.imageView.frame;
            self.isPanGesture = YES;
            
        } else {
            self.isPanGesture = NO;
            self.imageBrowser.collectionView.scrollEnabled = YES;
        }
    } else {
        if (self.isPanGesture) {
            CGFloat zoomScale = self.scrollView.contentOffset.y / self.dismissPanLength + 1;
            
            CGPoint point = [panGesture velocityInView:panGesture.view];

            //细节：是否继续下拉
            if (point.y > 0) {
                self.isWillDismiss = YES;
            } else {
                self.isWillDismiss = NO;
            }
            
            if (zoomScale < self.dismissZoomScale) {
                zoomScale = self.dismissZoomScale;
            } else if (zoomScale > self.minZoomScale) {
                zoomScale = self.minZoomScale;
            }
            
            CGPoint center = CGPointMake(self.panFrame.origin.x + self.panFrame.size.width/2.0,
                                         self.panFrame.origin.y + self.panFrame.size.height/2.0);
            
            center.x -= self.scrollView.contentOffset.x;
            center.y -= self.scrollView.contentOffset.y;
            
            CGSize size = [self imageSizeForScale:zoomScale];
            //缩小
            self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
            //平移
            self.imageView.center = center;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserCell:zoomScale:)])
            {
                [self.delegate browserCell:self zoomScale:zoomScale];
            }
            
            self.panScale = zoomScale;
        }
    }
}


- (void)doubleTapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    CGFloat aveScale = self.minZoomScale + (self.maxZoomScale - self.minZoomScale)/2.0;//中间倍数
    CGFloat zoomScale = _currentScale;
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if (self.currentScale > aveScale) {
        zoomScale = self.minZoomScale;
    } else if (self.currentScale < aveScale) {
        zoomScale = self.maxZoomScale;
    }
    
    if (self.currentScale != zoomScale) {
        _currentScale = zoomScale;
        
        //获取图片缩放后的frame
        CGRect rect = [self zoomImageForScale:zoomScale point:point centering:YES];
        rect = [self adjustImageFrame:rect];
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.imageView.frame = rect;
                         } completion:^(BOOL finished) {
                             [self adjustScrollFrame];
                         }];
    }
}


- (void)pinchGestureAction:(UIPinchGestureRecognizer *)pinchGesture
{
    self.isPanGesture = NO;

    if (pinchGesture.state == UIGestureRecognizerStateEnded ||
        pinchGesture.state == UIGestureRecognizerStateCancelled) {
        
        //如果大于图片的最小倍数，就仅仅调整图片的位置
        if (self.currentScale > self.minZoomScale) {
            
            CGRect rect = [self adjustImageFrame:self.imageView.frame];
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 self.imageView.frame = rect;
                             } completion:^(BOOL finished) {
                                 [self adjustScrollFrame];
                             }];
        } else if (self.currentScale < self.willDismissScale && self.isWillDismiss) {
            //如果小于了图片的最小倍数，且小于了消失的倍数，并且还继续缩小，就把图片缩小并消失
            [self dismissWithAnimation:YES];
        } else {
            //如果小于了图片的最小倍数，且大于了消失的倍数或者不还继续缩小，就把图片恢复到最小倍数
            [self dismissWithAnimation:NO];
            [UIView animateWithDuration:animationDuration animations:^{
                [self resetState];
            }];
        }
        
        self.scrollView.pinchGestureRecognizer.enabled = YES;
    } else {
        int touchCount = (int)pinchGesture.numberOfTouches;
        if (touchCount == 2) {
            
            CGFloat zoomScale = (pinchGesture.scale - 1) + self.currentScale;
            [pinchGesture setScale:1.0];
            
            zoomScale = zoomScale > self.maxZoomScale ? self.maxZoomScale : zoomScale;
            zoomScale = zoomScale < self.dismissZoomScale ? self.dismissZoomScale : zoomScale;
            
            //细节：是否有继续缩小的趋势
            if (zoomScale <= self.currentScale) {
                self.isWillDismiss = YES;
            } else {
                self.isWillDismiss = NO;
            }
            
            _currentScale = zoomScale;
            
            CGPoint p1 = [pinchGesture locationOfTouch: 0 inView:pinchGesture.view];
            CGPoint p2 = [pinchGesture locationOfTouch: 1 inView:pinchGesture.view];
            CGPoint center = CGPointMake((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0);
            
            CGRect rect = CGRectMake(center.x, center.y, 0, 0);
            CGRect newRect = [pinchGesture.view convertRect:rect toView:self.imageView];
            self.beginPinchCenter = CGPointMake(newRect.origin.x, newRect.origin.y);
            
            if (pinchGesture.state == UIGestureRecognizerStateBegan) {
                self.movePinchCenter = center;
            } else {
                //放大
                CGRect rect = [self zoomImageForScale:_currentScale point:self.beginPinchCenter centering:NO];
                
                //平移
                CGFloat x = center.x - self.movePinchCenter.x;
                CGFloat y = center.y - self.movePinchCenter.y;
                
                rect.origin.x += x;
                rect.origin.y += y;
                
                self.imageView.frame = rect;
                self.movePinchCenter = center;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserCell:zoomScale:)])
            {
                [self.delegate browserCell:self zoomScale:self.currentScale];
            }
        } else {
            self.scrollView.pinchGestureRecognizer.enabled = NO;
        }
    }
}

#pragma mark - 辅助函数
//图片缩放后的size
- (CGSize)imageSizeForScale:(CGFloat)scale
{
    UIImage *image = _imageView.image;
    CGFloat width = self.bounds.size.width;
    CGFloat height = width * image.size.height/image.size.width;
    return CGSizeMake(width * scale, height * scale);
}
/**
 图片缩放

 @param scale 倍数
 @param point 点击的位置
 @param isCenter 是否对焦
 @return 缩放过后的frame
 */
- (CGRect)zoomImageForScale:(CGFloat)scale
                      point:(CGPoint)point
                  centering:(BOOL)isCenter;
{
    CGSize size = [self imageSizeForScale:scale];
    CGRect imageRect = self.imageView.frame;
    
    //居中平移
    CGFloat center_offset_x =  (self.scrollView.contentOffset.x + self.scrollView.center.x) - (point.x+imageRect.origin.x);
    CGFloat center_offset_y =  (self.scrollView.contentOffset.y + self.scrollView.center.y) - (point.y+imageRect.origin.y);
    
    //放大平移
    CGFloat scale_offset_x = (point.x / imageRect.size.width) * (imageRect.size.width - size.width);
    CGFloat scale_offset_y = (point.y / imageRect.size.height) * (imageRect.size.height - size.height);
    
    CGFloat image_offset_x = imageRect.origin.x + scale_offset_x;
    CGFloat image_offset_y = imageRect.origin.y + scale_offset_y;
    
    if (isCenter) {
        image_offset_x = image_offset_x + center_offset_x;
        image_offset_y = image_offset_y + center_offset_y;
    }
    
    CGRect rect = CGRectMake(image_offset_x,image_offset_y,size.width,size.height);
    return rect;
}

//修正scroll的状态，适应imageview的大小
- (void)adjustScrollFrame
{
    CGSize size = self.imageView.frame.size;
    CGRect imageFrame = self.imageView.frame;
    
    CGFloat image_offset_x = (self.scrollView.frame.size.width - size.width) / 2.0;
    CGFloat image_offset_y = (self.scrollView.frame.size.height - size.height) / 2.0;
    
    image_offset_x = image_offset_x < 0 ? 0 : image_offset_x;
    image_offset_y = image_offset_y < 0 ? 0 : image_offset_y;
    
    self.imageView.frame = CGRectMake(image_offset_x, image_offset_y, size.width, size.height);
    
    CGFloat scroll_offset_x = self.scrollView.contentOffset.x - imageFrame.origin.x;
    CGFloat scroll_offset_y = self.scrollView.contentOffset.y - imageFrame.origin.y;
    
    CGRect rect = CGRectMake(scroll_offset_x, scroll_offset_y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    if (size.width < self.scrollView.frame.size.width) {
        size.width = self.scrollView.frame.size.width;
    }
    if (size.height < self.scrollView.frame.size.height) {
        size.height = self.scrollView.frame.size.height;
    }
    
    self.scrollView.contentSize = size;
    [self.scrollView scrollRectToVisible:rect animated:NO];
}

//当图片的frame小于屏幕大小的时候，做居中处理
//当图片的frame大于屏幕大小的时候，图片滑动不能超过屏幕的边边
- (CGRect)adjustImageFrame:(CGRect)rect
{
    CGFloat image_offset_x, image_offset_y;
    CGFloat scroll_offset_x, scroll_offset_y;
    scroll_offset_x = self.scrollView.contentOffset.x;
    scroll_offset_y = self.scrollView.contentOffset.y;
    CGRect scrollFrame = self.scrollView.frame;
    
    //当图片的宽大于屏幕大小的时候，图片滑动不能超过屏幕的边边
    if (rect.size.width > scrollFrame.size.width) {
        image_offset_x = rect.origin.x;
        if (rect.origin.x > scroll_offset_x) {
            image_offset_x = scroll_offset_x;
        } else if ((rect.origin.x + rect.size.width) < (scroll_offset_x + scrollFrame.size.width)) {
            image_offset_x = (scroll_offset_x + scrollFrame.size.width) - rect.size.width;
        }
    } else {
        //当图片的宽小于屏幕大小的时候，做居中处理
        image_offset_x = scroll_offset_x + (scrollFrame.size.width - rect.size.width) / 2.0;
        image_offset_x = image_offset_x < 0 ? 0 : image_offset_x;
    }
    
    //当图片的高大于屏幕大小的时候，图片滑动不能超过屏幕的边边
    if (rect.size.height > scrollFrame.size.height) {
        image_offset_y = rect.origin.y;
        if (rect.origin.y > scroll_offset_y) {
            image_offset_y = scroll_offset_y;
        } else if ((rect.origin.y + rect.size.height) < (scroll_offset_y + scrollFrame.size.height)) {
            image_offset_y = (scroll_offset_y + scrollFrame.size.height) - rect.size.height;
        }
    } else {
        //当图片的高小于屏幕大小的时候，做居中处理
        image_offset_y = scroll_offset_y + (scrollFrame.size.height - rect.size.height) / 2.0;
        image_offset_y = image_offset_y < 0 ? 0 : image_offset_y;
    }
    
    CGRect newRect = CGRectMake(image_offset_x, image_offset_y, rect.size.width, rect.size.height);
    return newRect;
}
#pragma mark - Setter / Getter
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        //开启弹性，不然图片小于屏幕了无法响应pan手势
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        
        //设置scrollView的缩放倍数，不然不响应pinch手势
        _scrollView.maximumZoomScale = self.maxZoomScale;
        _scrollView.minimumZoomScale = 0.1f;
        _scrollView.decelerationRate = 0.1f;
        _scrollView.delegate = self;
        
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(panGestureAction:)];
        [_scrollView.pinchGestureRecognizer addTarget:self action:@selector(pinchGestureAction:)];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        
        //双击手势
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureAction:)];
        _doubleTapGesture.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:_doubleTapGesture];
    }
    return _imageView;
}
- (void)setMaxZoomScale:(CGFloat)maxZoomScale
{
    if (_maxZoomScale != maxZoomScale) {
        _maxZoomScale = maxZoomScale;
        self.scrollView.maximumZoomScale = maxZoomScale;
    }
}
@end
