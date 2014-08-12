//
//  Photo.h
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Photo : NSObject

@property NSString *photoId;
@property CLLocation *location;
@property UIImage *image;
@property NSURL *imageURL;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
