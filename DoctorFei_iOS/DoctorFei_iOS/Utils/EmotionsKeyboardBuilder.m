//
//  EmotionsKeyboardBuilder.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/12.
//
//

#import "EmotionsKeyboardBuilder.h"

@implementation EmotionsKeyboardBuilder
+ (WUEmoticonsKeyboard *)sharedEmoticonsKeyboard {
    static WUEmoticonsKeyboard *_sharedEmoticonsKeyboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //create a keyboard of default size
        WUEmoticonsKeyboard *keyboard = [WUEmoticonsKeyboard keyboard];
        
        NSArray *textKeys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"]];
        
        NSMutableArray *itemArray = [NSMutableArray array];
        [textKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            WUEmoticonsKeyboardKeyItem *item = [[WUEmoticonsKeyboardKeyItem alloc]init];
            item.textToInput = obj;
            NSString *imageString = [NSString stringWithFormat:@"Expression_%d@2x", idx + 1];
            item.image = [UIImage imageNamed:imageString];
            [itemArray addObject:item];

        }];
//        //Icon keys
//        WUEmoticonsKeyboardKeyItem *loveKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        loveKey.image = [UIImage imageNamed:@"love"];
//        loveKey.textToInput = @"[love]";
//        
//        WUEmoticonsKeyboardKeyItem *applaudKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        applaudKey.image = [UIImage imageNamed:@"applaud"];
//        applaudKey.textToInput = @"[applaud]";
//        
//        WUEmoticonsKeyboardKeyItem *weicoKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        weicoKey.image = [UIImage imageNamed:@"weico"];
//        weicoKey.textToInput = @"[weico]";
        
        //Icon key group
        WUEmoticonsKeyboardKeyItemGroup *imageIconsGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
//        imageIconsGroup.keyItems = @[loveKey,applaudKey,weicoKey];
        imageIconsGroup.keyItems = [itemArray copy];
        UIImage *keyboardEmotionImage = [UIImage imageNamed:@"keyboard_emotion"];
        UIImage *keyboardEmotionSelectedImage = [UIImage imageNamed:@"keyboard_emotion_selected"];
        if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
            keyboardEmotionImage = [keyboardEmotionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            keyboardEmotionSelectedImage = [keyboardEmotionSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        imageIconsGroup.image = keyboardEmotionImage;
        imageIconsGroup.selectedImage = keyboardEmotionSelectedImage;
        
        //Set keyItemGroups
        keyboard.keyItemGroups = @[imageIconsGroup];
        
//        //Setup cell popup view
//        [keyboard setKeyItemGroupPressedKeyCellChangedBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, WUEmoticonsKeyboardKeyCell *fromCell, WUEmoticonsKeyboardKeyCell *toCell) {
//            [EmotionsKeyboardBuilder sharedEmotionsKeyboardKeyItemGroup:keyItemGroup pressedKeyCellChangedFromCell:fromCell toCell:toCell];
//        }];
        
        //Keyboard appearance
        
        //Custom text icons scroll background
//        if (textIconsLayout.collectionView) {
//            UIView *textGridBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [textIconsLayout collectionViewContentSize].width, [textIconsLayout collectionViewContentSize].height)];
//            textGridBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            textGridBackgroundView.backgroundColor = [UIColor lightGrayColor];
//            //            textGridBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyboard_grid_bg"]];
//            [textIconsLayout.collectionView addSubview:textGridBackgroundView];
//        }
//        
        //Custom utility keys
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_switch"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_del"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_switch_pressed"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateHighlighted];
        [keyboard setImage:[UIImage imageNamed:@"DeleteEmoticonBtn_ios7"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_del_pressed"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateHighlighted];
//        [keyboard setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Space", @"") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor darkGrayColor]}] forButton:WUEmoticonsKeyboardButtonSpace state:UIControlStateNormal];
//        [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forButton:WUEmoticonsKeyboardButtonSpace state:UIControlStateNormal];
//        
//        //Keyboard background
//        [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        
        [keyboard setBackgroundColor:UIColorFromRGB(0xDDDDDD) forKeyItemGroup:imageIconsGroup];
//        
//        //SegmentedControl
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_normal_selected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_selected_normal"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        
        _sharedEmoticonsKeyboard = keyboard;
    });
    return _sharedEmoticonsKeyboard;
}

//+ (void)sharedEmotionsKeyboardKeyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup
//             pressedKeyCellChangedFromCell:(WUEmoticonsKeyboardKeyCell *)fromCell
//                                    toCell:(WUEmoticonsKeyboardKeyCell *)toCell
//{
//    static WUDemoKeyboardPressedCellPopupView *pressedKeyCellPopupView;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        pressedKeyCellPopupView = [[WUDemoKeyboardPressedCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 83, 110)];
//        pressedKeyCellPopupView.hidden = YES;
//        [[self sharedEmoticonsKeyboard] addSubview:pressedKeyCellPopupView];
//    });
//    
//    if ([[self sharedEmoticonsKeyboard].keyItemGroups indexOfObject:keyItemGroup] == 0) {
//        [[self sharedEmoticonsKeyboard] bringSubviewToFront:pressedKeyCellPopupView];
//        if (toCell) {
//            pressedKeyCellPopupView.keyItem = toCell.keyItem;
//            pressedKeyCellPopupView.hidden = NO;
//            CGRect frame = [[self sharedEmoticonsKeyboard] convertRect:toCell.bounds fromView:toCell];
//            pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(pressedKeyCellPopupView.frame)/2);
//        }else{
//            pressedKeyCellPopupView.hidden = YES;
//        }
//    }
//}
//
@end
