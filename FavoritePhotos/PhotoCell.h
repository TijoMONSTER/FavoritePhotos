//
//  PhotoCell.h
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoCell : UICollectionViewCell

- (void)setImage:(UIImage *)image;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end
