//
//  TestCollectionViewCell.m
//  Test
//
//  Created by 伍小华 on 2017/5/9.
//  Copyright © 2017年 yuansiwei. All rights reserved.
//

#import "TestCollectionViewCell.h"
#import <Masonry/Masonry.h>
@implementation TestCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}
@end
