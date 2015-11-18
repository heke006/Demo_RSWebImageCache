//
//  HHPictureCell.h
//  HHDemo_Pictures
//
//  Created by hehai on 11/18/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHPictureCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (CGFloat)cellHeight;

@end
