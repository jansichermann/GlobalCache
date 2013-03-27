//
//  GlobalCache.m
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

#import "GlobalCache.h"


static const int maxDiskCacheSeconds = 8640;


@interface GlobalCache ()

@property (nonatomic, readwrite)    NSCache         *imageCache;
@property (nonatomic)               NSFileManager   *fm;
@property (atomic)                  NSMutableArray  *bgSaveForPathInProgress;

@end


@implementation GlobalCache

+ (GlobalCache *)shared {
    static dispatch_once_t once;
    static GlobalCache *shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.fm = [NSFileManager defaultManager];
        [self.fm createDirectoryAtPath:[self imageCacheDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
        self.bgSaveForPathInProgress = [NSMutableArray array];
    }
    return self;
}

- (void)setImage:(UIImage *)image forPath:(NSString *)pathString {
    if (image) {
        [self.imageCache setObject:image forKey:pathString];
    }
}

- (void)setData:(NSData *)data forPath:(NSString *)pathString {
    if (![self.bgSaveForPathInProgress containsObject:pathString]) {
        [self.bgSaveForPathInProgress addObject:pathString];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [data writeToFile:[self cachePathForImagePath:pathString] atomically:YES];
            [self.bgSaveForPathInProgress removeObject:pathString];
        });
    }
}

- (UIImage *)imageForPath:(NSString *)pathString {
    if ([self.imageCache objectForKey:pathString]) {
        return [self.imageCache objectForKey:pathString];
    }
    
    if ([self.fm fileExistsAtPath:[self cachePathForImagePath:pathString]]) {
        
        NSDictionary *fileAttributes = [self.fm attributesOfItemAtPath:[self cachePathForImagePath:pathString] error:nil];
        NSDate *modDate = [fileAttributes objectForKey:NSFileModificationDate];
        
        if ( fabs([modDate timeIntervalSinceNow]) < maxDiskCacheSeconds) {
            
            UIImage *image = [UIImage imageWithContentsOfFile:[self cachePathForImagePath:pathString]];
            [self setImage:image forPath:pathString];
            return image;
        }
        else {
            // cache out of date
            [self.fm removeItemAtPath:[self cachePathForImagePath:pathString] error:nil];
        }
    }
    return nil;
}

- (NSString *)cachePathForImagePath:(NSString *)imagePath {
    return [[self imageCacheDirPath] stringByAppendingPathComponent:[self escapeString:imagePath]];
}

- (NSString *)cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}


#pragma mark Cache Directories

- (NSString *)imageCacheDirPath {
    return [[self cachesDirectory] stringByAppendingPathComponent:@"images"];
}


- (NSString *)escapeString:(NSString *)string {
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                       kCFAllocatorDefault,
                                       (CFStringRef)string,
                                       NULL, // characters to leave unescaped
                                       (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                       kCFStringEncodingUTF8);
    return result;
}
@end
