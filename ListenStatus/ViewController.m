//
//  ViewController.m
//  FreePro
//
//  Created by wei.z on 2019/4/17.
//  Copyright © 2019 wei.z. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking/AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property(nonatomic,strong)AVAudioPlayer *player;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,strong)UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.label.textAlignment=NSTextAlignmentCenter;
    self.label.font=[UIFont systemFontOfSize:14];
    self.label.numberOfLines=0;
    [self.view addSubview:self.label];
    [self freerequest];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(freerequest) userInfo:nil repeats:YES];
}

-(void)freerequest{
    NSString *str = @"http://www.ziroom.com/detail/info?id=62345146&house_id=60369865";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&error];
        NSDictionary *data2=[myDictionary objectForKey:@"data"];
        if([data2[@"status"] isEqualToString:@"dzz"] && [data2[@"style_code"] intValue]==97001009){
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self play];
                 self.label.text=@"状态正常";
                 [self.timer invalidate];
                 self.timer=nil;
            }];
        }else{
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 self.label.text=[NSString  stringWithFormat:@"状态扫描中\n%@",[self getTime]];
             }];
        }
        
        if(error){
            NSLog(@"%@",error);
        }
    }];
    [task resume];
}

-(NSString *)getTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [formatter stringFromDate:currentDate];
    return currentDateString;
}

-(void)play{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"travelinglight.mp3" withExtension:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops=-1;
    [self.player prepareToPlay];
    if(self.player.isPlaying) {
        [self.player pause];
    }else{
        [self.player play];
    }
//    [self.player stop];
//    self.player.currentTime = 0;
}


-(void)freerequest2{
    
    __block long long second=[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue];
    __block int64_t download;
    __block long long totalsecond=[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue];
    
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.确定请求的URL地址
    NSURL *url = [NSURL URLWithString:@"https://vod.zjstv.com/video/2019/04/12/ee000b64590e9a4e91f572ee780259f0.mp4"];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //4.下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if(download){
            long long tempsecond=[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue];
            int64_t tempdata=downloadProgress.completedUnitCount;
            long long t=tempsecond-second;
            if(t>0){
                int64_t d=tempdata-download;
                NSLog(@"已下载:%.2fM 文件大小:%.2fM 下载进度:%.2f%% 实时网速:%.0fk/s 总计用时:%.0fs",1.0 * downloadProgress.completedUnitCount/1024/1024,1.0 * downloadProgress.totalUnitCount/1024/1024,1.0 * downloadProgress.completedUnitCount*100 / downloadProgress.totalUnitCount,d*1000/1024/t*1.0,1.0*(tempsecond-totalsecond)/1000);
                second=tempsecond;
                download=tempdata;
            }
        }else{
            second=[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue];
            download=downloadProgress.completedUnitCount;
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //设置下载路径，并将文件写入沙盒，最后返回NSURL对象
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"targetPath:\n%@",targetPath);
        NSLog(@"fullPath:\n%@",fullPath);
        return [NSURL fileURLWithPath:fullPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //NSLog(@"完成：%@--%@",response,filePath);
        NSHTTPURLResponse *response1 = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [response1 statusCode];
        if (statusCode == 200) {

        }else{
            //
        }
        
    }];
    
    //5.开始启动下载任务
    [task resume];
}
@end
