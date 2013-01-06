//
//  GlobalCache.h
//
//  Created by Jan Sichermann on 01/05/13.
//  Copyright (c) 2013 online in4mation GmbH. All rights reserved.
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

@interface GlobalCache : NSObject

+ (GlobalCache *)shared;

// set image sets the image in an on memory cache from which it may get evicted at any point
- (void)setImage:(UIImage *)image forPath:(NSString *)pathString;

// setData writes the data to disk
- (void)setData:(NSData *)data forPath:(NSString *)pathString;

- (UIImage *)imageForPath:(NSString *)pathString;
@end
