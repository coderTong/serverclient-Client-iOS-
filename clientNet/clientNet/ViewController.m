//
//  ViewController.m
//  clientNet
//
//  Created by codew on 2017/6/16.
//  Copyright © 2017年 codew. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()
///  主机地址
@property (weak, nonatomic) IBOutlet UITextField *hostnameTextC;
///  端口
@property (weak, nonatomic) IBOutlet UITextField *portTextC;
///  发送消息文本
@property (weak, nonatomic) IBOutlet UITextField *msgTextC;
///  接收文字标签
@property (weak, nonatomic) IBOutlet UILabel *recvLabelC;

///  客户端 socket
@property (nonatomic, assign) int clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)connectBtnClick:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([self connectTo:self.hostnameTextC.text port:self.portTextC.text.intValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.recvLabelC.text = @"连接成功";
                [self logRunloop];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.recvLabelC.text = @"连接失败";
            });
            
        }
    });
    
}

- (void)logRunloop
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char redStr[1024] = {0};
        NSString * redMsg;
        while (1) {
            if (self.clientSocket < 0) {
                NSLog(@"%s----断开连接", __func__);
                return;
            }
            read(self.clientSocket, redStr, sizeof(redStr));
            redMsg = [NSString stringWithUTF8String:redStr];
            NSLog(@"接受到数据: %@", redMsg);
            if (redMsg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.recvLabelC.text = redMsg;
                });
            }
        }
        
    });
}

- (IBAction)sendBtnClick:(id)sender {
//    self.recvLabelC.text = [self sendAndRecv:self.msgTextC.text];
    
    [self sendAndRecv:self.msgTextC.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///  连接到服务器
///
///  @param hostname 主机地址
///  @param port     端口号
///
///  @return 是否成功
- (BOOL)connectTo:(NSString *)hostname port:(int)port {
    // 1. socket
    /**
     参数
     
     domain:    协议域，AF_INET（IPV4的网络开发）
     type:      Socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(UDP，报文)
     protocol:  IPPROTO_TCP，协议，如果输入0，可以根据第二个参数，自动选择协议
     
     返回值
     socket，如果 > 0 就表示成功
     */
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (clientSocket < 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"socket 创建失败!!!." message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];;
        [alertView show];
    }
    self.clientSocket = clientSocket;
    
    // 2. 连接到服务器
    /**
     参数
     1> 客户端socket
     2> 指向数据结构sockaddr的指针，其中包括目的端口和IP地址
     服务器的"结构体"地址
     提示：C 语言中没有对象
     3> 结构体数据长度
     
     返回值
     0 成功/其他 错误代号，非0即真
     */
    struct sockaddr_in serverAddress;
    memset(&serverAddress, 0, sizeof(serverAddress));// 初始化
    // 协议族
    serverAddress.sin_family = AF_INET;
    // 主机地址 - inet_addr 函数可以把ip地址转换成一个整数
    serverAddress.sin_addr.s_addr = inet_addr("162.243.64.148");
    // 端口
    serverAddress.sin_port = htons(5189);
    
    int result = connect(clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    if (result < 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"连接失败!!!." message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];;
        [alertView show];
    }
    return (result == 0);
}

///  发送和接收消息
///
///  @param msg 发送给服务器的消息
///
///  @return 从服务器接收到的消息
- (void)sendAndRecv:(NSString *)msg {
    // 1. 发送消息
    /**
     参数
     1> 客户端socket
     2> 发送内容地址 void * == id
     3> 发送内容长度
     4> 发送方式标志，一般为0
     返回值
     如果成功，则返回发送的字节数，失败则返回SOCKET_ERROR
     */
    NSLog(@"%s", msg.UTF8String);
//    ssize_t sendLen = send(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
    
    write(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String));
    
//    NSLog(@"发送了 %ld 字节", sendLen);
    
    // 2. 接收消息
    /**
     参数
     1> 客户端socket
     2> 接收内容缓冲区地址
     3> 接收内容缓存区长度
     4> 接收方式，0表示阻塞，必须等待服务器返回数据
     返回值
     如果成功，则返回读入的字节数，失败则返回SOCKET_ERROR
     */
//    uint8_t buffer[100];
//    ssize_t recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
//    NSLog(@"接收到 %ld 字节", recvLen);
//    
//    NSData *data = [NSData dataWithBytes:buffer length:recvLen];
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    return str;
}

///  断开连接
- (IBAction)disconnection {
    // 1. 断开连接
    close(self.clientSocket);
    self.clientSocket = -1;
    NSLog(@"%s----断开连接", __func__);
}

@end
