//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "SearchViewController.h"
#import "Photo.h"
#import "PhotoCell.h"

#define urlToGetFlickrPhotos @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ac464ee6ed976f4f7c0e48e3152a24ad&format=json&nojsoncallback=1&has_geo=1&per_page=10&extras=url_z,geo&tag_mode=all&tags="

@interface SearchViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property NSMutableArray *searchedPhotos;
@property NSMutableArray *favoritePhotos;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.searchedPhotos = [NSMutableArray new];

	self.navigationController.navigationBarHidden = YES;

	[self load];

	if (!self.favoritePhotos) {
		self.favoritePhotos = [NSMutableArray new];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[self loadFlickrPhotosWithKeywords:searchBar.text];
}

- (void)loadFlickrPhotosWithKeywords:(NSString *)keywords
{
	[self.activityIndicator startAnimating];

	// take spaces out
	keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:@","];

	NSString *formedURLString = [NSString stringWithFormat:@"%@%@", urlToGetFlickrPhotos, keywords];
	NSURL *url = [NSURL URLWithString: formedURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (!connectionError) {
			NSError *error;
			NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

			if (!error) {
				// no errors :)
				if (self.searchedPhotos.count > 0) {
					[self.searchedPhotos removeAllObjects];
				}

				for (NSDictionary *photoDictionary in decodedJSON[@"photos"][@"photo"]) {
					Photo *photo = [[Photo alloc] initWithDictionary:photoDictionary];
					[self.searchedPhotos addObject:photo];
				}

				[self.activityIndicator stopAnimating];
				[self.collectionView reloadData];
				NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				[self.collectionView scrollToItemAtIndexPath:firstItemIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

			} else {
				// error decoding json
				[self showAlertViewWithTitle:@"Error" message:error.localizedDescription buttonText:@"OK"];
			}
		} else {
			// connection error
			[self showAlertViewWithTitle:@"Connection error" message:connectionError.localizedDescription buttonText:@"OK"];
		}
	}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.searchedPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Photo *photo = self.searchedPhotos[indexPath.row];
	PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];

	if (!photo.image) {

		[cell showActivityIndicator];
		// download image
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:photo.imageURL];
		[NSURLConnection sendAsynchronousRequest:urlRequest
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

								   if (!connectionError) {
									   photo.image = [UIImage imageWithData:data];
									   [cell setImage:photo.image];
									   [cell hideActivityIndicator];
								   }
								   // connection error
								   else {
									   if ([connectionError.localizedDescription isEqualToString: @"bad URL"]) {
										   photo.image = [UIImage imageNamed:@"photo_placeholder"];
										   [cell setImage:photo.image];
										   [cell hideActivityIndicator];
									   }
									   [self showAlertViewWithTitle:@"Connection error" message:connectionError.localizedDescription buttonText:@"OK"];
								   }
							   }];
	} else {
		[cell setImage:photo.image];
	}

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *photoCell = (PhotoCell *)cell;
	[photoCell setImage:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *photoCell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
	Photo *photo = (Photo *)self.searchedPhotos[indexPath.row];

	if (!photo.favorited) {
		photo.favorited = YES;

		// save state
		NSString *imageURLString = [photo.imageURL relativeString];
		[self.favoritePhotos addObject:imageURLString];
		[self save];
	}
}

#pragma Persistence

- (NSURL *)documentsDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *directories = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	NSLog(@"%@", directories.firstObject);
	return directories.firstObject;
}

- (void)savePhotoToDocumentsDirectory:(Photo *)photo
{
//	NSString path = [NSString stringWithFormat:@"%@", photo.photoId];

//	NSURL *imageURL =[[self documentsDirectory] URLByAppendingPathComponent:];
}

- (void)save
{
	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];
//	NSLog(@"%@", plist);
//	NSLog(@"%@", self.favoritePhotos);

	NSLog(@"%d success!",[self.favoritePhotos writeToURL:plist atomically:YES]);
}

- (void)load
{
	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];
	self.favoritePhotos = [NSMutableArray arrayWithContentsOfURL:plist];
}

#pragma mark - Helper methods

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonText:(NSString *)buttonText
{
	UIAlertView *alertView = [UIAlertView new];
	alertView.title = title;
	alertView.message = message;
	[alertView addButtonWithTitle:buttonText];
	[alertView show];
	NSLog(@"%@", message);
}

@end
