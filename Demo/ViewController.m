//
//  ViewController.m
//  Test
//
//  Created by 伍小华 on 2017/5/5.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "WXHImageBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TestCollectionViewCell.h"

@interface ViewController ()<WXHImageBrowserDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WXHImageBrowser *imageBrowser;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[
                       @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1494316376&di=a3836f6be1a8089f5628cdcd180b1df0&src=http://img27.51tietu.net/pic/2017-011500/20170115001256mo4qcbhixee164299.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306682777&di=f66ef8d58caa407d13de74b441fe53f6&imgtype=0&src=http%3A%2F%2Fimg1.juimg.com%2F160806%2F355860-160P620130540.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306737856&di=385bc180dc85d6a340413ec7f8199bd0&imgtype=0&src=http%3A%2F%2Fpic39.nipic.com%2F20140309%2F251960_211736384000_2.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306779341&di=26f746cb67f893647295440216de264d&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F130728%2F318764-130HPQ60163.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306864215&di=ac4159bdbab8c0e6d3c88f66029b1751&imgtype=0&src=http%3A%2F%2Fi2.sinaimg.cn%2Fedu%2F2015%2F0522%2FU7638P42DT20150522101916.jpg",
                       @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1494316376&di=a3836f6be1a8089f5628cdcd180b1df0&src=http://img27.51tietu.net/pic/2017-011500/20170115001256mo4qcbhixee164299.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306682777&di=f66ef8d58caa407d13de74b441fe53f6&imgtype=0&src=http%3A%2F%2Fimg1.juimg.com%2F160806%2F355860-160P620130540.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306737856&di=385bc180dc85d6a340413ec7f8199bd0&imgtype=0&src=http%3A%2F%2Fpic39.nipic.com%2F20140309%2F251960_211736384000_2.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306779341&di=26f746cb67f893647295440216de264d&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F130728%2F318764-130HPQ60163.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494306864215&di=ac4159bdbab8c0e6d3c88f66029b1751&imgtype=0&src=http%3A%2F%2Fi2.sinaimg.cn%2Fedu%2F2015%2F0522%2FU7638P42DT20150522101916.jpg"];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@(150));
        make.centerY.equalTo(self.view);
    }];
}

- (void)buttonAction:(UIButton *)button
{
    self.imageBrowser.dataArray = self.dataArray;
    self.imageBrowser.currentIndex = button.tag - 1000;
    self.imageBrowser.appearFrame = [self.view convertRect:button.frame toView:self.imageBrowser];
    self.imageBrowser.disappearFrame = [self.view convertRect:button.frame toView:self.imageBrowser];
    [self.imageBrowser show];
}
- (void)imageBrowser:(WXHImageBrowser *)imageBrowser scrollToIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        TestCollectionViewCell *cell = (TestCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.imageBrowser.disappearFrame = [self.imageBrowser convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    }];
}
- (CGRect)imageBrowser:(WXHImageBrowser *)imageBrowser disappearFrameForIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    TestCollectionViewCell *cell = (TestCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return [self.imageBrowser convertRect:cell.imageView.frame fromView:cell.imageView.superview];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:self.dataArray[indexPath.row] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TestCollectionViewCell *cell = (TestCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.imageBrowser.dataArray = self.dataArray;
    self.imageBrowser.appearFrame = [self.imageBrowser convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    self.imageBrowser.disappearFrame = [self.imageBrowser convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    self.imageBrowser.currentIndex = indexPath.row;
    [self.imageBrowser show];
}

#pragma mark - Setter / Getter
- (WXHImageBrowser *)imageBrowser
{
    if (!_imageBrowser) {
        _imageBrowser = [[WXHImageBrowser alloc] init];
        _imageBrowser.placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
        _imageBrowser.delegate = self;
    }
    return _imageBrowser;
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 20;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(200, 150);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    return _collectionView;
}
@end
