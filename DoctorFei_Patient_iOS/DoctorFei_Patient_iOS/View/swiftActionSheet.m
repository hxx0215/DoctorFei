//
//  swiftActionSheet.m
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/12/15.
//
//

#import "swiftActionSheet.h"

@implementation swiftActionSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)show{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.delegate cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"照片", nil];
    [sheet showInView:self.father];
}
@end
