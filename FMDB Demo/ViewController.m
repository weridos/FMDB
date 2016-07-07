//
//  ViewController.m
//  FMDB Demo
//
//  Created by Lymn on 6/7/16.
//  Copyright © 2016 Andy. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
@interface ViewController ()
@property(nonatomic,strong)FMDatabase *db;
@property(nonatomic,strong)NSString *fileName;
@end
NSString *const studentTable = @"studentTable";
NSString *const studentName = @"studentName";
NSString *const studentID = @"studentID";
NSString *const studentAddress = @"studentAddress";
NSString * const studentScore = @"studentScore";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.获取数据库文件路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:self.fileName];
    
    //3.打开数据库
    if([db open])
    {
       //4.创建表：首先判断表是否存在
        if(![db tableExists:studentTable])
        {
            NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE %@ (%@ INTEGER PRIMARY KEY, %@ TEXT, %@ TEXT, %@ INTEGER) ",studentTable,studentID,studentName,studentAddress,studentScore];
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (res) {
                NSLog(@"create studentTable success!");
            }else
            {
                NSLog(@"create studentTable fail!");
            }

        }else
        {
            NSLog(@"studentTable had existed");
        }
        
    }
    self.db = db;
    
}
- (IBAction)insertData:(id)sender {
    NSArray *nameArray = @[@"LiMing",@"LiLei",@"ZhangSan",@"HanMei",@"WangWu",@"ZhaoLiu",@"XiaoHua"];
    NSArray *addressArray = @[@"长沙",@"郑州",@"武汉",@"石家庄",@"北京",@"上海",@"杭州"];
    for(int i = 1;i <= nameArray.count;i++)
    {
        NSString *name = nameArray[i-1];
        NSString *ID = [NSString stringWithFormat:@"%d",i];
        NSString *address  = addressArray[i-1];
        NSString *score = [NSString stringWithFormat:@"%d",arc4random() %100];
        //5.插入数据：两种方式
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (?,?,?,?)"];
        //executeUpdate 不确定参数用？来占位
        BOOL res = [self.db executeUpdate:insertSql,ID,name,address,score];
        
        //executeUpdateWithFormat 不确定参数用%@、%d等来占位
//        BOOL res = [self.db executeUpdateWithFormat:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (%@,%@,%@,%@)",ID,name,address,score];

        if (!res) {
            NSLog(@"error when insert");
        } else {
            NSLog(@"success to insert");
        }
        
    }
}
- (IBAction)alterData:(id)sender {
    //6.更新数据
    NSString *updateSql = [NSString stringWithFormat:
                           @"UPDATE %@ SET %@ = %@ WHERE %@ = %@",
                           studentTable,  studentScore,  @"80" ,studentID, @"2"];
    BOOL res = [self.db executeUpdate:updateSql];
    if (!res) {
        NSLog(@"error when update db table");
    } else {
        NSLog(@"success to update db table");
    }
}
- (IBAction)deleteData:(id)sender {
    //删除整个表
//    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",studentTable];
//    BOOL res = [self.db executeUpdate:deleteSql];
    
    //7.删除一条数据
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@",studentTable,studentID,@"5"];
    BOOL res = [self.db executeUpdate:deleteSql];
    if (!res) {
        NSLog(@"error when delete db table");
    } else {
        NSLog(@"success to delete db table");
    }
    
}

- (IBAction)queryData:(id)sender {
    //8.查询数据
    NSString * sql = [NSString stringWithFormat:
                      @"SELECT * FROM %@",studentTable];
    FMResultSet * rs = [self.db executeQuery:sql];
    while ([rs next]) {
        int Id = [rs intForColumn:studentID];
        NSString * name = [rs stringForColumn:studentName];
        int score = [rs intForColumn:studentScore];
        NSString * address = [rs stringForColumn:studentAddress];
        NSLog(@"id = %d, name = %@, score = %d  address = %@", Id, name, score, address);
    }
    [self.db close];
}
- (void)multithreading
{
    //使用数据库文件地址来初使化FMDatabaseQueue
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.fileName];
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (?,?,?,?)",@"10",@"ZhangWei",@"北京",@"80"];
        [db executeUpdate:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (?,?,?,?)",@"11",@"XiaoXue",@"上海",@"90"];
        FMResultSet *rs = [db executeQuery:@"select * from studentTable"];
        while ([rs next]) {
            int Id = [rs intForColumn:studentID];
            NSString * name = [rs stringForColumn:studentName];
            int score = [rs intForColumn:studentScore];
            NSString * address = [rs stringForColumn:studentAddress];
            NSLog(@"id = %d, name = %@, score = %d  address = %@", Id, name, score, address);

        }
    }];
}
- (void)transaction
{
    //使用事务
    BOOL isRollBack = NO;
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.fileName];
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (?,?,?,?)",@"10",@"ZhangWei",@"北京",@"80"];
        [db executeUpdate:@"INSERT INTO studentTable (studentID,studentName,studentAddress,studentScore) VALUES (?,?,?,?)",@"11",@"XiaoXue",@"上海",@"90"];
        if (isRollBack) {
            *rollback = YES;
        }
    }];
    isRollBack = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
