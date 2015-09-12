//
//  HMDownLoadOperation.m
//  SDWebImagePrac
//
//  Created by RainShen on 15/9/11.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import "HMDownLoadOperation.h"

@implementation HMDownLoadOperation
/**
 *  重写main方法的注意点：自己创建自动释放池（因为如果是异步，在子线程中无法访问主线程的自动释放池）
 *  经常通过 - (Bool)isCancelled操作检查操作是否被取消，对取消做出响应
 */
- (void)main {

//    @autoreleasepool {
        
 //       if (self.isCancelled) return; //这里检查一开始是否被取消干掉了
        
        NSURL * url = [NSURL URLWithString:self.imageUrl];
        
        NSData * data = [NSData dataWithContentsOfURL:url]; //做下载
        
        UIImage * image = [UIImage imageWithData:data]; //NSData -> UIImage
        self.image = image;
//        if (self.cancelled) return; //这里就是操作既然被取消了，被干掉了，就不要往下执行主线程通知代理了
        
        //上面已经下载完了，那下载完做什么啊，是不是要回到主线程刷新UI啊，复制控制器里面的代码后，发现所有要做的事情都是控制器知道，而当前类只负责下载，下载完要做什么不知道，只是帮别人跑腿的，所以下载完要通知别人，这时应该用代理，回传给控制器一些值，看到下面警告就知道所有要做的事情都是控制器在做了,只要成为了operation代理，就能监听下载过程，下载完会通知控制器
        /* [[NSOperationQueue mainQueue] addOperationWithBlock:^{
         
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
         
         }];*/
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            //代理回到主线程做事
////            if ([self.delegate respondsToSelector:@selector(downLoadOperation:didFinishDownLoad:)]) {
////                [self.delegate downLoadOperation:self didFinishDownLoad:image];
////            }
//            
//            if (self.block) {
//                self.block(image);
//            }
//            
//        }];
 //   }

}

- (void)downLoadBlock:(DownLoadOperationBLock)loadBLock {
    @autoreleasepool {
        if (self.cancelled) return;
        [self main];
        if (self.cancelled) return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           
            loadBLock(self.image);
        }];
    }
    
}

@end
