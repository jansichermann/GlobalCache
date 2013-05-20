#import "GlobalCacheTest.h"
#import "GlobalCache.h"

@interface GlobalCache ()

@property (atomic) NSMutableArray *bgSaveForPathInProgress;
- (NSData *)_dataForPath:(NSString *)pathString;
- (UIImage *)_imageInMemoryCacheForPath:(NSString *)path;

@end



@implementation GlobalCacheTest

- (void)testSingleton {
    STAssertNotNil([GlobalCache shared], @"Expected Global Cache");
    STAssertEquals([GlobalCache shared], [GlobalCache shared], @"Expected Global Cache to be a singleton");
}

- (void)testCacheSetterRetrieval {
    UIImage *image = [[UIImage alloc] init];
    NSString *path = @"asdf";
    STAssertNoThrow([[GlobalCache shared] setImage:image forPath:path], @"Expected to be able to set image to cache");
    STAssertEquals([[GlobalCache shared] imageForPath:path], image, @"Expected to return same image as set");
}

- (void)testCachePersistance {
    UIImage *image = [self randomImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = @"imagePath";
    [[GlobalCache shared] setData:imageData forPath:imagePath];
    // the save process happens in a background thread, so we wait for it to finish
    while ([[GlobalCache shared].bgSaveForPathInProgress containsObject:imagePath]) {
        sleep(0.1);
    }
    UIImage *retrievedImage = [[GlobalCache shared] imageForPath:imagePath];
    STAssertNotNil(retrievedImage, @"Expected retrieved image");
    STAssertEqualObjects(imageData, [[GlobalCache shared] _dataForPath:imagePath], @"Expected retrieved Data to match");
    STAssertNotNil([[GlobalCache shared] _imageInMemoryCacheForPath:imagePath], @"Expected image to also be set in in-memory Cache");
}

- (UIImage *)randomImage {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(NULL,
                          300,
                          300,
                          8,
                          0,
                          colorSpace,
                          kCGImageAlphaPremultipliedLast);
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)1.0 );
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return [UIImage imageWithCGImage:cgImage];
}
    
@end
