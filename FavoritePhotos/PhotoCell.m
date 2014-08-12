//
//  PhotoCell.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteMark;

@end

@implementation PhotoCell

- (void)setImage:(UIImage *)image
{
	self.imageView.image = image;
//	[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)showActivityIndicator
{
	[self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator
{
	[self.activityIndicator stopAnimating];
}

- (void)setFavorite:(BOOL)favorited
{
	self.favoriteMark.hidden = !favorited;
}

@end
