//
//  Photo.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "Photo.h"

@interface Photo ()

@end

@implementation Photo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];

	self.photoId = dictionary[@"id"];
	self.location = [[CLLocation alloc]
					 initWithLatitude:[dictionary[@"latitude"] floatValue]
					 longitude:[dictionary[@"longitude"] floatValue]];
	self.imageURL = [NSURL URLWithString:dictionary[@"url_z"]];
	return self;
}

@end
