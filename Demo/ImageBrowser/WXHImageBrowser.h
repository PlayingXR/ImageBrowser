//
//  WXHImageBrowser.h
//  Test
//
//  Created by Jerry on 2017/5/6.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXHImageBrowser;
@protocol WXHImageBrowserDelegate <NSObject>

@optional
- (void)imageBrowser:(WXHImageBrowser *)imageBrowser scrollToIndex:(NSInteger)index;
- (CGRect)imageBrowser:(WXHImageBrowser *)imageBrowser disappearFrameForIndex:(NSInteger)index;
@end
@interface WXHImageBrowser : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) CGRect appearFrame;
@property (nonatomic, assign) CGRect disappearFrame;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) id<WXHImageBrowserDelegate> delegate;
@property (nonatomic, strong) UIImage *placeholderImage;

- (void)show;
- (void)dismiss:(BOOL)isAnimation;
@end
