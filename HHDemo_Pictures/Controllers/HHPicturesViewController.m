//
//  HHPicturesViewController.m
//  HHDemo_Pictures
//
//  Created by hehai on 11/18/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import "HHPicturesViewController.h"
#import "HHPictureCell.h"
#import "HHPictureModel.h"

@interface HHPicturesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HHPictureModel *pictureModel;
@property (nonatomic, strong) NSMutableArray *pictureArr;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *imagesDic;
@property (nonatomic, strong) NSString *cachesPath;

@end

@implementation HHPicturesViewController

#pragma mark - Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.queue cancelAllOperations];
    [self.imagesDic removeAllObjects];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pictures";
    
    [self.view addSubview:self.tableView];
    
    [self.pictureArr addObjectsFromArray:self.pictureModel.pictureArr];
}

#pragma mark - tableView dataSource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pictureArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"HHPictureCell";
    HHPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];

    cell.titleLabel.text = [NSString stringWithFormat:@"第%ld行测试用数据", indexPath.row];
    
    [self setImageForCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HHPictureCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.pictureArr removeObjectAtIndex:indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - private method

- (void)setImageForCell:(HHPictureCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    UIImage *image = self.imagesDic[self.pictureArr[indexPath.row]];
    if (image) {
        cell.titleImageView.image = image;
        NSLog(@"hit memory:%@",self.pictureArr[indexPath.row]);
    } else {
        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[self.pictureArr[indexPath.row] lastPathComponent]];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            cell.titleImageView.image = [UIImage imageWithData:data];
            NSLog(@"hit disk:%@",self.pictureArr[indexPath.row]);
        } else {
            cell.titleImageView.image = [UIImage imageNamed:@"placeHolder"];
            // 开始下载
            [self downloadImageAtIndexPath:indexPath];
        }
    }
    
}

- (void)downloadImageAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *str = weakSelf.pictureArr[indexPath.row];
        NSURL *url = [NSURL URLWithString:str];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.timeoutInterval = 20;
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *iconData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (iconData.length < 1) {
            NSLog(@"error:%@", error);
            return;
        }
        
        NSLog(@"下载完毕：%@", weakSelf.pictureArr[indexPath.row]);

        UIImage *image = [UIImage imageWithData:iconData];
        if (image != nil) {
            weakSelf.imagesDic[weakSelf.pictureArr[indexPath.row]] = image;
        }
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString *filePath = [weakSelf.cachesPath stringByAppendingPathComponent:[weakSelf.pictureArr[indexPath.row] lastPathComponent]];
        [data writeToFile:filePath atomically:YES];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            HHPictureCell *cell = (HHPictureCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"indexPath:%@", indexPath);
            if (iconData.length < 1) {
                NSLog(@"未下载");
            }
            cell.titleImageView.image = [UIImage imageWithData:iconData];
        }];    
    }];
    
    [weakSelf.queue addOperation:operation];

}

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"HHPictureCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HHPictureCell"];
    }
    return _tableView;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSMutableDictionary *)imagesDic {
    if (!_imagesDic) {
        _imagesDic = [NSMutableDictionary new];
    }
    return _imagesDic;
}

- (NSString *)cachesPath {
    if (!_cachesPath) {
        _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
    return _cachesPath;
}

- (NSMutableArray *)pictureArr {
    if (!_pictureArr) {
        _pictureArr = [[NSMutableArray alloc] init];
    }
    return _pictureArr;
}

- (HHPictureModel *)pictureModel {
    if (!_pictureModel) {
        _pictureModel = [[HHPictureModel alloc] init];
    }
    return _pictureModel;
}

@end
