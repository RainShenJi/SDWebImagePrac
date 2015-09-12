//
//  HMAppsViewController.m
//  SDWebImagePrac
//
//  Created by RainShen on 15/9/7.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import "HMAppsViewController.h"
#import "HMApp.h"
#import "HMDownLoadOperation.h"

@interface HMAppsViewController ()<HMDownLoadOperationDelegate>

@property (nonatomic, strong) NSMutableArray * apps;
/**
 *  存放所有下载操作的队列
 */
@property (nonatomic, strong) NSOperationQueue * queue;
/**
 *  存放所有的下载操作
 */
@property (nonatomic, strong) NSMutableDictionary * operations;
/**
 *  存放下载完的图片
 */
@property (nonatomic, strong) NSMutableDictionary * images;

@end

@implementation HMAppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.queue = [[NSOperationQueue alloc] init];

}

#pragma mark - 懒加载

- (NSMutableArray *)apps {
    
    if (!_apps) {
        
        NSMutableArray * tempArr = [NSMutableArray array];
        NSString * file = [[NSBundle mainBundle] pathForResource:@"apps" ofType:@"plist"];
        NSArray * array = [NSArray arrayWithContentsOfFile:file];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            HMApp * app = [HMApp appWithDict:obj]; //将字典放入模型
            [tempArr addObject:app];
        }];
        self.apps = tempArr;
    }
    return _apps;
}

- (NSOperationQueue *)queue {
    
    if (!_queue) {
        
        self.queue = [[NSOperationQueue alloc] init];;
    }
    return _queue;
}

- (NSMutableDictionary *)operations {
    
    if (!_operations) {
        
        self.operations = [[NSMutableDictionary alloc] init];
    }
    return _operations;
}

- (NSMutableDictionary *)images {
    
    if (!_images) {
        
        self.images = [[NSMutableDictionary alloc] init];
    }
    return _images;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static  NSString * ID = @"app";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    HMApp * app = self.apps[indexPath.row];
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
   // [self downloadImage:app.icon tableView:tableView indexPath:indexPath];
    //首先应该取出当前图片url对应的下载操作是否存在
    
    //先从images
    UIImage * image = self.images[app.icon];
    if (image == nil) { //说明图片并未下载成功（并未缓存过）
        
        //先从沙河中取图片
        NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //  NSLog(@"caches : %@", caches);
        //拼接路径
        NSString * fileName = [app.icon lastPathComponent];
        NSString * file = [caches stringByAppendingPathComponent:fileName];
        //上面三句代码可以合成一个，完了写成宏，可以传进去一个url
        NSData * data = [NSData dataWithContentsOfFile:file];
        if (data) {
            
            cell.imageView.image = [UIImage imageWithData:data];
        } else {
            
            cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];

        }
        
        //下载图片
        [self downLoadImage:app.icon indexPath:indexPath];
        
    }else{ //说明图片成功下载（成功缓存）
        cell.imageView.image = image;
    }
    
    tableView.rowHeight = 80;
    
    return cell;
}

#pragma mark - custom methods

- (void)downLoadImage:(NSString *)urlString indexPath:(NSIndexPath *)indexPath {

   // NSBlockOperation * blockOperation = self.operations[urlString];
    HMDownLoadOperation * blockOperation = self.operations[urlString];
    if (blockOperation) return; //去掉上面的大括号
    
    //创建操作
    //__weak HMAppsViewController * appvc = self; //第一种写法
    __weak typeof(self) appvc = self; //第二种写法
    /*
     typeof 判断类型，self就是HMAppsViewController * 这个类型,举个例子：
     int age = 20;
     typeof(30) age2 = 10; 其中30是int类型，和上面定义等价
     typeof(age) age3 = 50;
     */

  /*  blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        //   [NSThread sleepForTimeInterval:5];
        NSURL * url = [NSURL URLWithString:urlString];
        
        NSData * data = [NSData dataWithContentsOfURL:url]; //做下载
        
        UIImage * image = [UIImage imageWithData:data];
        
        //回到主线程,主线程做事情，所以这个blockOperation做的只是上面三行
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // cell.imageView.image = image; //直接下载会造成图片错乱问题，尽管最后恢复正常，这是由于cell复用问题，当第一个cell下载图片未完成时，用户向下滚动，这个cell进入复用池，当从复用池取出时，图片已下载完成，所以会先看到这个图片，然后当前这个复用的cell也去请求图片了去服务器（需要花时间），取回来后再覆盖这个已经下载了的图片，所以这个方法就不要用了
            
            
            
            //存放图片到字典中
            
            if (image) {
                
                appvc.images[urlString] = image; //加if语句防止image为nil，由于字典不能放nil，否则会崩溃的,另外这里会产生循环引用,那怎么办呢？将其中一个置为弱引用,两个办法
                
                
                
                //往沙盒存图片
                
                //UIImage -> UIData -> file
                
                NSData * data = UIImageJPEGRepresentation(image, 1.0);
                
                
                
                //获得caches的路径
                
                NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                
                //  NSLog(@"caches : %@", caches);
                
                //拼接路径
                
                NSString * fileName = [urlString lastPathComponent];
                
                NSString * file = [caches stringByAppendingPathComponent:fileName];
                
                //  NSLog(@"file : %@",file);
                
                [data writeToFile:file atomically:YES];
                
                
                
            }
            
            
            
            //下载完成后移除下载操作以免字典越来越大,也可以防止下载失败，if语句不进来，但是删除后，也不对，因为删除后if语句也会一直走，这时怎么办呢？
            
            [appvc.operations removeObjectForKey:urlString];
            
            
            
            //刷新表格,就会重新调用当前表格
            
            //  [self.tableView reloadData];
            
            //但是上面这个会刷新所有表格，影响性能，所以最好刷新对应的表格
            
            [appvc.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
    }];
   */
    blockOperation = [[HMDownLoadOperation alloc] init];
    blockOperation.imageUrl = urlString; //在这里知道自己下载什么了，不迷茫了，下载完就告诉他的代理
    //设置代理
  //  blockOperation.delegate = self;
    blockOperation.indexpath = indexPath;
    [self.queue addOperation:blockOperation]; //一旦这里添加操作就调用operation的main方法，所以在HMDownLoadOperation里面实现main方法，在其里面写要做的事情
        //添加到字典中，解决重复下载
//    blockOperation.block = ^(UIImage * image){
// 
//    };
    [blockOperation downLoadBlock:^(UIImage *image) {
       
        if (image) {
            
            appvc.images[urlString] = image; //加if语句防止image为nil，由于字典不能放nil，否则会崩溃的,另外这里会产生循环引用,那怎么办呢？将其中一个置为弱引用,两个办法
            
            
            
            //往沙盒存图片
            
            //UIImage -> UIData -> file
            
            NSData * data = UIImageJPEGRepresentation(image, 1.0);
            
            
            
            //获得caches的路径
            
            NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
            NSLog(@"caches : %@", caches);
            
            //拼接路径
            
            NSString * fileName = [urlString lastPathComponent];
            
            NSString * file = [caches stringByAppendingPathComponent:fileName];
            
            NSLog(@"file : %@",file);
            
            [data writeToFile:file atomically:YES];
            
            
            
        }
        
        
        
        //下载完成后移除下载操作以免字典越来越大,也可以防止下载失败，if语句不进来，但是删除后，也不对，因为删除后if语句也会一直走，这时怎么办呢？
        
        [appvc.operations removeObjectForKey:urlString];
        
        
        
        //刷新表格,就会重新调用当前表格
        
        //  [self.tableView reloadData];
        
        //但是上面这个会刷新所有表格，影响性能，所以最好刷新对应的表格
        
        [appvc.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    self.operations[urlString] = blockOperation;
}

//- (void)downLoadOperation:(HMDownLoadOperation *)operation didFinishDownLoad:(UIImage *)image {
//    
//    //存放图片到字典中
//    
//    if (image) {
//        
//        self.images[operation.imageUrl] = image; //加if语句防止image为nil，由于字典不能放nil，否则会崩溃的,另外这里会产生循环引用,那怎么办呢？将其中一个置为弱引用,两个办法
//        
//        
//        
//        //往沙盒存图片
//        
//        //UIImage -> UIData -> file
//        
//        NSData * data = UIImageJPEGRepresentation(image, 1.0);
//        
//        
//        
//        //获得caches的路径
//        
//        NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        
//        //  NSLog(@"caches : %@", caches);
//        
//        //拼接路径
//        
//        NSString * fileName = [operation.imageUrl lastPathComponent];
//        
//        NSString * file = [caches stringByAppendingPathComponent:fileName];
//        
//        //  NSLog(@"file : %@",file);
//        
//        [data writeToFile:file atomically:YES];
//        
//        
//        
//    }
//    
//    
//    
//    //下载完成后移除下载操作以免字典越来越大,也可以防止下载失败，if语句不进来，但是删除后，也不对，因为删除后if语句也会一直走，这时怎么办呢？
//    
//    [self.operations removeObjectForKey:operation.imageUrl];
//    
//    
//    
//    //刷新表格,就会重新调用当前表格
//    
//    //  [self.tableView reloadData];
//    
//    //但是上面这个会刷新所有表格，影响性能，所以最好刷新对应的表格
//    
//    [self.tableView reloadRowsAtIndexPaths:@[operation.indexpath] withRowAnimation:UITableViewRowAnimationNone];
//}

#pragma mark - system delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    [self.queue setSuspended:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    [self.queue setSuspended:NO];
}


- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    
    [self.queue cancelAllOperations];
    [self.images removeAllObjects];
    [self.operations removeAllObjects];
}

/**
 *  1.由于在主线程下载图片，NSData * imageData = [NSData dataWithContentsOfURL:url];很耗时的，因为要去服务器拿数据，会阻塞主线程,影响用户体验（怎么解决）
    2.会重复下载，浪费流量，浪费时间，影响用户体验（怎么解决）
 我们要保证一张图片只下载一次，怎么保证啊，一个NSOperation就代表一个下载操作
 答：查看url对应的下载操作是否已经存在，如果存在，就不要重复下载了，这个时候要用的是字典
    3.图片会错乱
 */

//- (void)downloadImage:(NSString *)urlStr tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
//    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    __block UIImage * image = nil;
//    dispatch_async(queue, ^{
//        NSURL * url = [NSURL URLWithString:urlStr];
//        NSData * imageData = [NSData dataWithContentsOfURL:url];
//        image = [UIImage imageWithData:imageData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//           cell.imageView.image = image;
//        });
//    });
//}

@end
