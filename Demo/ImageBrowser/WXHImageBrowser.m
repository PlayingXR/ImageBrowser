//
//  WXHImageBrowser.m
//  Test
//
//  Created by Jerry on 2017/5/6.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import "WXHImageBrowser.h"
#import "WXHImageBrowserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define BROWSER_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define BROWSER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface WXHImageBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource,WXHImageBrowserCellDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation WXHImageBrowser
static NSString* cellIdentifier = @"CellIdentifier";
- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, BROWSER_SCREEN_WIDTH, BROWSER_SCREEN_HEIGHT);
        
        [self addSubview:self.collectionView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationAction)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.flowLayout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    self.collectionView.frame = self.bounds;
}

- (void)show
{
    //刷新CollectionView
    [self.collectionView reloadData];
    
    [self layoutIfNeeded];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    //找到指定Cell执行放大动画
    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        //滚动到指定位置
        WXHImageBrowserCell *cell = (WXHImageBrowserCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell showWithAnimation];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self];
        [self showAnimation];
    }];
}

- (void)dismiss:(BOOL)isAnimation
{
    if (isAnimation) {
        [self dismissAnimation];
    } else {
        [self removeFromSuperview];
    }
}
- (void)showAnimation
{
    [UIView animateWithDuration:animationDuration animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }];
}
- (void)dismissAnimation
{
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)orientationAction
{
    self.frame = CGRectMake(0, 0, BROWSER_SCREEN_WIDTH, BROWSER_SCREEN_HEIGHT);
    [self layoutIfNeeded];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}




#pragma mark - WXHImageBrowserCellDelegate
- (void)browserCell:(WXHImageBrowserCell *)cell zoomScale:(CGFloat)scale
{
    if (scale <= cell.minZoomScale) {
        CGFloat alpha = (scale - cell.dismissZoomScale) / cell.dismissZoomScale;
        alpha = alpha < 0.1 ? 0.1 : alpha;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    }
}

- (void)browserCell:(WXHImageBrowserCell *)cell dissmiss:(BOOL)finished
{
    if (finished) {
        [self dismissAnimation];
    } else {
        [self showAnimation];
    }
}

- (CGRect)appearRectOfBrowserCell:(WXHImageBrowserCell *)cell
{
    return self.appearFrame;
}
- (CGRect)disappearRectOfBrowserCell:(WXHImageBrowserCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageBrowser:disappearFrameForIndex:)]) {
        self.disappearFrame = [self.delegate imageBrowser:self disappearFrameForIndex:self.currentIndex];
    }
    return self.disappearFrame;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXHImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.imageBrowser = self;
    cell.delegate = self;
    
    id imagePath = self.dataArray[indexPath.row];
    if ([imagePath isKindOfClass:[UIImage class]]) {
        cell.imageView.image = imagePath;
    } else if ([imagePath isKindOfClass:[NSString class]] && [self isImagePath:imagePath]) {
        UIImage *image = [UIImage imageNamed:imagePath];
        if (image) {
            cell.imageView.image = image;
        } else {
            image = [UIImage imageWithContentsOfFile:imagePath];
            if (image) {
                cell.imageView.image = image;
            } else {
                [cell.imageView sd_setImageWithURL:imagePath
                                  placeholderImage:self.placeholderImage
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             [cell resetState];
                                         }];
            }
        }
    } else {
        cell.imageView.image = self.placeholderImage;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXHImageBrowserCell *aCell = (WXHImageBrowserCell *)cell;
    [aCell resetState];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    if (index != self.currentIndex) {
        self.currentIndex = index;
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageBrowser:scrollToIndex:)]) {
            [self.delegate imageBrowser:self scrollToIndex:self.currentIndex];
        }
    }
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        [_collectionView registerClass:[WXHImageBrowserCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    return _collectionView;
}

- (BOOL)isImagePath:(NSString *)path
{
    if (path) {
        NSString *pathExtension = [path pathExtension];
        if (pathExtension) {
            pathExtension = [pathExtension lowercaseString];
            if([pathExtension isEqualToString:@"jpg"] ||
               [pathExtension isEqualToString:@"gif"] ||
               [pathExtension isEqualToString:@"png"] ||
               [pathExtension isEqualToString:@"jpeg"] ||
               [pathExtension isEqualToString:@"bmp"])
            {
                return YES;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
