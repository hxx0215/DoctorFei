//
//  JSQAudioMediaItem.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import "JSQMediaItem.h"

@interface JSQAudioMediaItem : JSQMediaItem <JSQMessageMediaData, NSCopying, NSCoding>

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL isReadyToPlay;
- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay;

- (void)startPlaySound;
- (void)endPlaySound;
- (BOOL)isPlaying;

@end
