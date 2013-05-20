//
//  GlobalCache.h
//
//  Created by Jan Sichermann on 01/05/13.
//  Copyright (c) 2013 Jan Sichermann. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>

/**
 GlobalCache is a Class providing a singleton to be used to cache images and the corresponding Data. It's an in-memory cache, with functions to persist the data to disk.
 */

@interface GlobalCache : NSObject

+ (GlobalCache *)shared;

/**
 @param image The image to be cached
 @param pathString The path with which the image can be retrieved.
 @discussion This will set the image to an in-memory cache. It DOES NOT write the image data to disk. The path is simply used retrieve the image. If the image is also persisted with setData:forPath: the image can simply be retrieved from either in memory or disk.
 */
- (void)setImage:(UIImage *)image forPath:(NSString *)pathString;

/**
 @param data The Image Data to be saved to disk
 @param pathString The path to which to persist the data
 @discussion The path should most likely match what was used in the corresponding setImage:forPath: call in order to not hit the disk every time the image is retrieved
 */
- (void)setData:(NSData *)data forPath:(NSString *)pathString;

/**
 @param pathString The Path as an NSString that references the image (either from disk, from in-memory cache, or both)
 @return The UIImage or nil
 */
- (UIImage *)imageForPath:(NSString *)pathString;

@end
