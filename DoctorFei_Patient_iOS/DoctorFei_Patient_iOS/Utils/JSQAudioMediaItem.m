//
//  JSQAudioMediaItem.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import "JSQAudioMediaItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

@interface JSQAudioMediaItem ()
@property (strong, nonatomic) UIView *cachedAudioImageView;
@property (strong, nonatomic) UIImageView *voiceStateView;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation JSQAudioMediaItem

- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedAudioImageView = nil;
    }
    return self;
}

- (void)dealloc
{
    _fileURL = nil;
    _cachedAudioImageView = nil;
}
#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedAudioImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedAudioImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedAudioImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedAudioImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIView *imageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        if (self.appliesMediaViewMaskAsOutgoing) {
            imageView.backgroundColor = UIColorFromRGB(0xADE85B);
            _voiceStateView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_animation_white3"]];
            [_voiceStateView setFrame:CGRectMake(20, 12, 20, 20)];
            _voiceStateView.animationImages = @[[UIImage imageNamed:@"chat_animation_white1"],
                                                [UIImage imageNamed:@"chat_animation_white2"],
                                                [UIImage imageNamed:@"chat_animation_white3"]];
//            _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 50, 22)];
//            _timeLabel.textAlignment = NSTextAlignmentRight;
//            [_timeLabel setTextColor:[UIColor blackColor]];
        }
        else{
            imageView.backgroundColor = [UIColor whiteColor];
            _voiceStateView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_animation3"]];
            [_voiceStateView setFrame:CGRectMake(110, 12, 20, 20)];
            _voiceStateView.animationImages = @[[UIImage imageNamed:@"chat_animation1"],
                                                [UIImage imageNamed:@"chat_animation2"],
                                                [UIImage imageNamed:@"chat_animation3"]];
//            _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 10, 50, 22)];
//            _timeLabel.textAlignment = NSTextAlignmentLeft;
//            [_timeLabel setTextColor:[UIColor whiteColor]];
        }
        _voiceStateView.animationDuration = 1;
        _voiceStateView.animationRepeatCount = 0;
        [imageView addSubview:_voiceStateView];
        
//        [_timeLabel setFont:[UIFont systemFontOfSize:14.0f]];
//        [_timeLabel setText:@"60''"];
//        [imageView addSubview:_timeLabel];
        //        [_voiceStateView startAnimating];
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedAudioImageView = imageView;
    }
    
    return self.cachedAudioImageView;
}
- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(150, 44);
}

#pragma mark - Actions
- (void)startPlaySound {
    [_voiceStateView startAnimating];
}
- (void)endPlaySound {
    [_voiceStateView stopAnimating];
}
- (BOOL)isPlaying {
    return [_voiceStateView isAnimating];
}


@end
