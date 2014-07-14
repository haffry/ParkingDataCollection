//
//  DetailsViewController.m
//  ParkingDataCollection
//
//  Created by 史奕鹏deMac on 14-7-9.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>{
    BOOL isFullScreen;
    BOOL isAnimationRepeat;
}

@property (strong, nonatomic) UIScrollView  *myscrollview;
@property (strong, nonatomic) UITextField   *textField_parkingAddress;
@property (strong, nonatomic) UITextField   *textField_parkingName;
@property (strong, nonatomic) UITextField   *textField_price;
@property (strong, nonatomic) UITextField   *textField_author;
@property (strong, nonatomic) UITextView    *textView_details;

@property (strong, nonatomic) UIButton      *button_ground;
@property (strong, nonatomic) UIButton      *button_underground;
@property (strong, nonatomic) UIButton      *button_pavement;

@property (strong, nonatomic) UIButton      *button_firstImage;
@property (strong, nonatomic) UIButton      *button_secondImage;
@property (strong, nonatomic) UIButton      *button_thirdImage;
@property (strong, nonatomic) UIButton      *button_fourthImage;

@property (strong, nonatomic) UIButton      *button_firstLocate;
@property (strong, nonatomic) UIButton      *button_secondLocate;
@property (strong, nonatomic) UIButton      *button_thirdLocate;
@property (strong, nonatomic) UIButton      *button_fourthLocate;

@property (strong, nonatomic) UIButton      *button_price;
@property (strong, nonatomic) UIButton      *button_removePriceView;
@property (strong, nonatomic) UIButton      *button_savePrice;
@property (strong, nonatomic) UIButton      *button_save;

@property (strong, nonatomic) UILabel       *label_firstCoordinates;
@property (strong, nonatomic) UILabel       *label_secondCoordinates;
@property (strong, nonatomic) UILabel       *label_thirdCoordinates;
@property (strong, nonatomic) UILabel       *label_fourthCoordinates;

@property (strong, nonatomic) UISwitch      *switch_firstEntrance;
@property (strong, nonatomic) UISwitch      *switch_secondEntrance;
@property (strong, nonatomic) UISwitch      *switch_thirdEntrance;
@property (strong, nonatomic) UISwitch      *switch_fourthEntrance;

@property (strong, nonatomic) UIView        *view_price;
@property (strong, nonatomic) UIView        *view_addPrice;

@property (strong, nonatomic) UITextField   *textField_priceDay;
@property (strong, nonatomic) UITextField   *textField_priceNight;
@property (strong, nonatomic) UITextField   *textField_priceByTime;
@property (strong, nonatomic) UITextField   *textField_priceMonthly;
@end

@implementation DetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textField_parkingAddress   = (UITextField *)[self.view viewWithTag:100];
    self.textField_parkingName      = (UITextField *)[self.view viewWithTag:101];
    self.textField_price            = (UITextField *)[self.view viewWithTag:102];
    self.textField_author           = (UITextField *)[self.view viewWithTag:104];
    self.textView_details           = (UITextView  *)[self.view viewWithTag:103];
    
    self.button_ground              = (UIButton    *)[self.view viewWithTag:200];
    self.button_underground         = (UIButton    *)[self.view viewWithTag:201];
    self.button_pavement            = (UIButton    *)[self.view viewWithTag:202];
    
    self.button_firstImage          = (UIButton    *)[self.view viewWithTag:203];
    self.button_secondImage         = (UIButton    *)[self.view viewWithTag:204];
    self.button_thirdImage          = (UIButton    *)[self.view viewWithTag:205];
    self.button_fourthImage         = (UIButton    *)[self.view viewWithTag:206];
    
    self.button_firstLocate         = (UIButton    *)[self.view viewWithTag:207];
    self.button_secondLocate        = (UIButton    *)[self.view viewWithTag:208];
    self.button_thirdLocate         = (UIButton    *)[self.view viewWithTag:209];
    self.button_fourthLocate        = (UIButton    *)[self.view viewWithTag:210];
    
    self.button_save                = (UIButton    *)[self.view viewWithTag:210];
    
    self.button_price               = (UIButton    *)[self.view viewWithTag:700];
    self.button_removePriceView     = (UIButton    *)[self.view viewWithTag:701];
    self.button_savePrice           = (UIButton    *)[self.view viewWithTag:702];
    
    self.label_firstCoordinates     = (UILabel     *)[self.view viewWithTag:300];
    self.label_secondCoordinates    = (UILabel     *)[self.view viewWithTag:301];
    self.label_thirdCoordinates     = (UILabel     *)[self.view viewWithTag:302];
    self.label_fourthCoordinates    = (UILabel     *)[self.view viewWithTag:303];
    
    self.switch_firstEntrance       = (UISwitch    *)[self.view viewWithTag:400];
    self.switch_secondEntrance      = (UISwitch    *)[self.view viewWithTag:401];
    self.switch_thirdEntrance       = (UISwitch    *)[self.view viewWithTag:402];
    self.switch_fourthEntrance      = (UISwitch    *)[self.view viewWithTag:403];
   
    self.textField_priceDay         = (UITextField *)[self.view viewWithTag:500];
    self.textField_priceNight       = (UITextField *)[self.view viewWithTag:501];
    self.textField_priceByTime      = (UITextField *)[self.view viewWithTag:502];
    self.textField_priceMonthly     = (UITextField *)[self.view viewWithTag:503];
    
    self.view_price                 = (UIView      *)[self.view viewWithTag:999];
    self.view_addPrice              = (UIView      *)[self.view viewWithTag:-999];
    
    //iOS7ScrollView适配问题
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    isAnimationRepeat=NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.myscrollview=(UIScrollView*)[self.view viewWithTag:111];
    self.myscrollview.bounces=NO;
    self.myscrollview.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.myscrollview.showsHorizontalScrollIndicator = NO;
    self.myscrollview.alwaysBounceVertical=NO;
    self.myscrollview.userInteractionEnabled=YES;
    CGSize newSize = CGSizeMake(0,830);
    [self.myscrollview setContentSize:newSize];
    [self.myscrollview setContentOffset:CGPointMake(0, 0)];

}

- (IBAction)touchesBegan:(id)sender {
    //当捕捉到触摸事件时，取消UITextField的第一相应
    [self.textField_author resignFirstResponder];
    [self.textField_parkingAddress resignFirstResponder];
    [self.textField_parkingName resignFirstResponder];
    [self.textField_price resignFirstResponder];
    [self.textView_details resignFirstResponder];
    
}
#pragma mark - 停车场类型按钮响应事件
- (IBAction)parkingTypeBtnClick:(id)sender {
    
    [self textFieldLosesFocus];
    NSInteger irc=[sender tag];
    switch (irc) {
        case 200:
        {
            self.button_ground.selected=YES;
            [self.button_ground setBackgroundImage:[UIImage imageNamed:@"地上地下选择_pressed"] forState:UIControlStateNormal];
            self.button_pavement.selected=NO;
            [self.button_pavement setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            self.button_underground.selected=NO;
            [self.button_underground setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            
            
        }
            break;
        case 201:
        {
            self.button_ground.selected=NO;
            [self.button_ground setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            self.button_pavement.selected=NO;
            [self.button_pavement setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            self.button_underground.selected=YES;
            [self.button_underground setBackgroundImage:[UIImage imageNamed:@"地上地下选择_pressed"] forState:UIControlStateNormal];
            
        }
            break;
        case 202:
        {
            self.button_ground.selected=NO;
            [self.button_ground setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            self.button_pavement.selected=YES;
            [self.button_pavement setBackgroundImage:[UIImage imageNamed:@"地上地下选择_pressed"] forState:UIControlStateNormal];
            self.button_underground.selected=NO;
            [self.button_underground setBackgroundImage:[UIImage imageNamed:@"地上地下选择"] forState:UIControlStateNormal];
            
        }
            break;
        default:
            
        break;
    }
}

#pragma mark - 拍照按钮响应事件
- (IBAction)cameraBtnClick:(id)sender {
    
    [self textFieldLosesFocus];
    
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
    
    
    NSInteger irc=[sender tag];
    switch (irc) {
        case 203:
        {
        }
            break;
        case 204:
        {
        }
            break;
        case 205:
        {
        }
            break;
        case 206:
        {
        }
            break;
        default:
            
        break;
    }
    
}
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
    }
}
#pragma mark - imagePicker 委托
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString* date = [formatter stringFromDate:[NSDate date]];
    [self saveImage:image withName:[[NSString alloc] initWithFormat:@"%@", date]];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@", date]];
    
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    isFullScreen = NO;
    
    [self.button_firstImage setBackgroundImage:savedImage forState:UIControlStateNormal];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}


#pragma mark - 移除金额view
- (IBAction)animationBtnClick:(id)sender {
    [self textFieldLosesFocus];
    
    float frameH=[[UIScreen mainScreen] bounds].size.height;
    NSInteger irc=[sender tag];
    switch (irc) {
        case 700:
        {
            [UIView animateWithDuration:0.3f animations:^{
                
                CGRect frame = self.view_price.frame;
                frame.origin.y -= frameH;
                self.view_price.frame = frame;
                
            } completion:^(BOOL finished) {
            }];

        }
            break;
        case 701:
        {

            //关闭当前填写价格页面
            [self closePriceView];
        }
            break;
        case 702:
        {
            //完成填写价格保存
            [self closePriceView];
        }
            break;
        default:
            
            break;
    }
    
    
    
}
-(void)closePriceView{
    
    float frameH=[[UIScreen mainScreen] bounds].size.height;
    isAnimationRepeat=NO;
    if (self.view_addPrice.frame.origin.y == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect frame = self.view_addPrice.frame;
            frame.origin.y += 100;
            self.view_addPrice.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
        
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        CGRect frame = self.view_price.frame;
        frame.origin.y += frameH;
        self.view_price.frame = frame;
        
    } completion:^(BOOL finished) {
    }];

}
#pragma mark - 定位按钮响应事件
- (IBAction)locateBtnClick:(id)sender {
     [self textFieldLosesFocus];
    
    NSInteger irc=[sender tag];
    switch (irc) {
        case 207:
        {
        }
            break;
        case 208:
        {
        }
            break;
        case 209:
        {
        }
            break;
        case 210:
        {
        }
            break;
        default:
            
            break;
    }
    

}

#pragma mark - 选择主入口响应事件
- (IBAction)mainEntranceSBtnClick:(id)sender {
     [self textFieldLosesFocus];
    
    NSInteger irc=[sender tag];
    switch (irc) {
        case 400:
        {
        }
            break;
        case 401:
        {
        }
            break;
        case 402:
        {
        }
            break;
        case 403:
        {
        }
            break;
        default:
            
            break;
    }

}

#pragma mark - UITextViewDelegate 委托
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    NSLog(@"textViewDidBeginEditing");
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    NSLog(@"textViewDidEndEditing");
}

- (void)leaveEditMode {
    
    NSLog(@"leaveEditMode");
}

#pragma mark - UIScrollViewDelegate 委托

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewDidEndScrollingAnimation");
}
#pragma mark -
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([[UIScreen mainScreen] bounds].size.height !=568) {
        
        if (!isAnimationRepeat) {
            isAnimationRepeat =YES;
    
            [UIView animateWithDuration:0.3f animations:^{
                
                CGRect frame = self.view_addPrice.frame;
                frame.origin.y -= 100;
                self.view_addPrice.frame = frame;
                
            } completion:^(BOOL finished) {
            }];

        }
    }
    
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSInteger irec=[textField tag];
    
    switch (irec) {
        case 500:
        {
            [self.textField_priceNight becomeFirstResponder];
        }
            break;
        case 501:
        {
            [self.textField_priceByTime becomeFirstResponder];
        }
            break;
        case 502:
        {
            [self.textField_priceMonthly becomeFirstResponder];
        }
            break;
        case 503:
        {
            isAnimationRepeat=NO;
            
            if ([[UIScreen mainScreen] bounds].size.height !=568) {
                [UIView animateWithDuration:0.3f animations:^{
                
                    CGRect frame = self.view_addPrice.frame;
                    frame.origin.y += 100;
                    self.view_addPrice.frame = frame;
                
                } completion:^(BOOL finished) {
                }];
            }

            
            [self.textField_priceDay     resignFirstResponder];
            [self.textField_priceNight   resignFirstResponder];
            [self.textField_priceByTime  resignFirstResponder];
            [self.textField_priceMonthly resignFirstResponder];
            
            
        }
            break;
        default:
            
            break;
    }

    return YES;
}
-(void)textFieldLosesFocus{
    
    [self.textField_priceDay     resignFirstResponder];
    [self.textField_priceNight   resignFirstResponder];
    [self.textField_priceByTime  resignFirstResponder];
    [self.textField_priceMonthly resignFirstResponder];
    
    
    [self.textField_author resignFirstResponder];
    [self.textField_parkingAddress resignFirstResponder];
    [self.textField_parkingName resignFirstResponder];
    [self.textField_price resignFirstResponder];
    [self.textView_details resignFirstResponder];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
