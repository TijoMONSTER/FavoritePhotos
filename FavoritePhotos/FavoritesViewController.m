//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PhotoCell.h"
#import "SearchViewController.h"

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property NSMutableArray *favoritePhotosIds;

@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;
	[self load];

	if (!self.favoritePhotosIds) {
		self.favoritePhotosIds = [NSMutableArray new];

		UIAlertView *alertView = [UIAlertView new];
		alertView.message = @"No favorites, tap the search button to finde some.";
		[alertView addButtonWithTitle:@"OK"];
		[alertView show];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.favoritePhotosIds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];

	NSString *photoID = self.favoritePhotosIds[indexPath.row];
	UIImage *loadedImage = [self loadPhotoWithId:photoID];
	[cell setImage:loadedImage];

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *pCell = (PhotoCell *)cell;
	[pCell setImage:nil];
}

#pragma mark - Segues

- (IBAction)unwindFromSearchViewController:(UIStoryboardSegue *)segue
{
	SearchViewController *searchVC = (SearchViewController *)segue.sourceViewController;

	Photo *selectedFavoritePhoto = [searchVC selectedFavoritePhoto];
	[self.favoritePhotosIds addObject:selectedFavoritePhoto.photoId];
	[self savePhoto:selectedFavoritePhoto];

	NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.collectionView scrollToItemAtIndexPath:firstItemIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
	[self.collectionView reloadData];
}

#pragma mark - Persistence

- (NSURL *)documentsDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *directories = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	return directories.firstObject;
}

- (void)savePhoto:(Photo *)photo
{
	NSURL *imageURL = [[self documentsDirectory] URLByAppendingPathComponent:photo.photoId];
	NSData *data = UIImagePNGRepresentation(photo.image);
	[data writeToURL:imageURL atomically:YES];

	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];
	NSLog(@"%d success!",[self.favoritePhotosIds writeToURL:plist atomically:YES]);
}

- (UIImage *)loadPhotoWithId:(NSString *)photoId
{
	NSURL *imageURL = [[self documentsDirectory] URLByAppendingPathComponent:photoId];
	NSData *data = [NSData dataWithContentsOfURL:imageURL];
	return [UIImage imageWithData:data];
}

- (void)load
{
	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];
	self.favoritePhotosIds = [NSMutableArray arrayWithContentsOfURL:plist];
}


@end
