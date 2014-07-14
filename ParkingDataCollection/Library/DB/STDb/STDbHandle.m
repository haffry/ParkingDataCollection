//
//  STDbHandle.m
//  STQuickKit
//
//  Created by yls on 13-11-21.
//
// Version 1.0.4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "STDbHandle.h"
#import <objc/runtime.h>


#ifdef DEBUG
#ifdef STDBBUG
#define STDBLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define STDBLog(...)
#endif
#else
#define STDBLog(...)
#endif

enum {
    DBObjAttrInt,
    DBObjAttrFloat,
    DBObjAttrString,
    DBObjAttrData,
    DBObjAttrDate,
    DBObjAttrArray,
    DBObjAttrDictionary,
};

#define DBText  @"text"
#define DBInt   @"integer"
#define DBFloat @"real"
#define DBData  @"blob"

@interface NSDate (STDbDate)

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

@end

@implementation NSDate (STDbDate)

+ (NSDate *)dateWithString:(NSString *)s;
{
    if (!s || (NSNull *)s == [NSNull null] || [s isEqual:@""]) {
        return nil;
    }
//    NSTimeInterval t = [s doubleValue];
//    return [NSDate dateWithTimeIntervalSince1970:t];
    
    return [[self dateFormatter] dateFromString:s];
}

+ (NSString *)stringWithDate:(NSDate *)date;
{
    if (!date || (NSNull *)date == [NSNull null] || [date isEqual:@""]) {
        return nil;
    }
//    NSTimeInterval t = [date timeIntervalSince1970];
//    return [NSString stringWithFormat:@"%lf", t];
    return [[self dateFormatter] stringFromDate:date];
}

+ (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return dateFormatter;
}

@end

@interface NSObject (STDbObject)

+ (id)objectWithString:(NSString *)s;
+ (NSString *)stringWithObject:(NSObject *)obj;

@end

@implementation NSObject (STDbObject)

+ (id)objectWithString:(NSString *)s;
{
    if (!s || (NSNull *)s == [NSNull null] || [s isEqual:@""]) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}
+ (NSString *)stringWithObject:(NSObject *)obj;
{
    if (!obj || (NSNull *)obj == [NSNull null] || [obj isEqual:@""]) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@interface STDbHandle()

@property(nonatomic)sqlite3  *sqlite3DB;
@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, strong) FMDatabase *fmdb;

@end

@implementation STDbHandle

/**
 *	@brief	单例数据库
 *
 *	@return	单例
 */
+ (instancetype)shareDb
{
    static STDbHandle *stdb;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        stdb = [[STDbHandle alloc] init];
        
        
    });
    
    return stdb;
  
}

/**
 *	@brief	从外部导入数据库
 *
 *	@param 	dbName 	数据库名称（dbName.db）
 */
+ (void)importDb:(NSString *)dbName
{
    NSString *dbPath = [STDbHandle dbPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        NSString *ext = [dbName pathExtension];
        NSString *extDbName = [dbName stringByDeletingPathExtension];
        NSString *extDbPath = [[NSBundle mainBundle] pathForResource:extDbName ofType:ext];
        if (extDbPath) {
            NSError *error;
            BOOL rc = [[NSFileManager defaultManager] copyItemAtPath:extDbPath toPath:dbPath error:&error];
            if (rc) {
                NSArray *tables = [STDbHandle sqlite_tablename];
                for (NSString *table in tables) {
                    NSMutableString *sql;
                    
                    sqlite3_stmt *stmt = NULL;
                    NSString *str = [NSString stringWithFormat:@"select sql from sqlite_master where type='table' and tbl_name='%@'", table];
                    STDbHandle *stdb = [STDbHandle shareDb];
                    [STDbHandle openDb];
                    if (sqlite3_prepare_v2(stdb->_sqlite3DB, [str UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
                        while (SQLITE_ROW == sqlite3_step(stmt)) {
                            const unsigned char *text = sqlite3_column_text(stmt, 0);
                            sql = [NSMutableString stringWithUTF8String:(const char *)text];
                        }
                    }
                    sqlite3_finalize(stmt);
                    stmt = NULL;
                    
                    NSRange r = [sql rangeOfString:@"("];
                    
                    // 备份数据库
                    
                    // 错误信息
                    char *errmsg = NULL;
                    
                    // 创建临时表
                    NSString *createTempDb = [NSString stringWithFormat:@"create temporary table t_backup%@", [sql substringFromIndex:r.location]];
                    int ret = sqlite3_exec(stdb.sqlite3DB, [createTempDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                    
                    //导入数据
                    NSString *importDb = [NSString stringWithFormat:@"insert into t_backup select * from %@", table];
                    ret = sqlite3_exec(stdb.sqlite3DB, [importDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                    // 删除旧表
                    NSString *dropDb = [NSString stringWithFormat:@"drop table %@", table];
                    ret = sqlite3_exec(stdb.sqlite3DB, [dropDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                    // 创建新表
                    NSMutableString *createNewTl = [NSMutableString stringWithString:sql];
                    if (r.location != NSNotFound) {
                        NSString *insertStr = [NSString stringWithFormat:@"\n\t%@ %@ primary key,", kDbId, DBInt];
                        [createNewTl insertString:insertStr atIndex:r.location + 1];
                    } else {
                        return;
                    }
                    NSString *createDb = [NSString stringWithFormat:@"%@", createNewTl];
                    ret = sqlite3_exec(stdb.sqlite3DB, [createDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                    
                    // 从临时表导入数据到新表
                    
                    NSString *cols = [[NSString alloc] init];
                    
                    NSString *t_str = [sql substringWithRange:NSMakeRange(r.location + 1, [sql length] - r.location - 2)];
                    t_str = [t_str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    t_str = [t_str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    t_str = [t_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSMutableArray *colsArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSString *s in [t_str componentsSeparatedByString:@","]) {
                        NSString *s0 = [NSString stringWithString:s];
                        s0 = [s0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSArray *a = [s0 componentsSeparatedByString:@" "];
                        NSString *s1 = a[0];
                        s1 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        [colsArr addObject:s1];
                    }
                    cols = [colsArr componentsJoinedByString:@", "];
                    
                    importDb = [NSString stringWithFormat:@"insert into %@ select (rowid-1) as %@, %@ from t_backup", table, kDbId, cols];
                    
                    ret = sqlite3_exec(stdb.sqlite3DB, [importDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                    
                    // 删除临时表
                    dropDb = [NSString stringWithFormat:@"drop table t_backup"];
                    ret = sqlite3_exec(stdb.sqlite3DB, [dropDb UTF8String], NULL, NULL, &errmsg);
                    if (ret != SQLITE_OK) {
                        NSLog(@"%s", errmsg);
                    }
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
            
        } else {
            
        }
    }
}

/**
 *	@brief	打开数据库
 *
 *	@return	成功标志
 */
+ (BOOL)openDb
{
    NSString *dbPath = [STDbHandle dbPath];
    STDbHandle *db = [STDbHandle shareDb];
    db.fmdb = [FMDatabase databaseWithPath:dbPath];
    int flags = SQLITE_OPEN_READWRITE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        flags = SQLITE_OPEN_READWRITE;
    } else {
        flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
    }
    
    if ([STDbHandle isOpened]) {
        
//        STDBLog(@"数据库已打开");
        return YES;
    }
    
    int rc = sqlite3_open_v2([dbPath UTF8String], &db->_sqlite3DB, flags, NULL);
 
    
    if ([db.fmdb openWithFlags:flags]) {
        if (rc == SQLITE_OK) {
            //        STDBLog(@"打开数据库%@成功!", dbPath);
            
            db.isOpened = YES;
            return YES;
        } else {
            STDBLog(@"打开数据库%@失败!", dbPath);
            return NO;
        }
        db.isOpened = YES;
        return YES;
    }else {
        STDBLog(@"打开数据库%@失败!", dbPath);
        db.isOpened = NO;
        return NO;
    }
    
    return NO;
}

/*
 * 关闭数据库
 */
+ (BOOL)closeDb {
    
#ifdef STDBBUG
    NSString *dbPath = [STDb dbPath];
#endif
    
    STDbHandle *db = [STDbHandle shareDb];
    
    if (![db isOpened]) {
//        STDBLog(@"数据库已关闭");
        return YES;
    }
    
    if ([db.fmdb close]) {
//        STDBLog(@"关闭数据库%@成功!", dbPath);
        db.isOpened = NO;
        
        return YES;
    } else {
        STDBLog(@"关闭数据库%@失败!", dbPath);
        return NO;
    }
    return YES;
}

/**
 *	@brief	数据库路径
 *
 *	@return	数据库路径
 */
+ (NSString *)dbPath
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", document, DBName];
    return path;
}

/**
 *	@brief	根据aClass表 添加一列
 *
 *	@param 	aClass 	表相关类
 *	@param 	columnName 	列名
 */
+ (void)dbTable:(Class)aClass addColumn:(NSString *)columnName
{
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"alter table "];
    [sql appendString:NSStringFromClass(aClass)];
    if ([columnName isEqualToString:kDbId]) {
        NSString *colStr = [NSString stringWithFormat:@"%@ %@ primary key", kDbId, DBInt];
        [sql appendFormat:@" add column %@;", colStr];
    } else {
        [sql appendFormat:@" add column %@ %@;", columnName, DBText];
    }

    
    STDbHandle *db = [STDbHandle shareDb];
    BOOL result = [db.fmdb executeUpdate:sql];
    if (!result) {
        
        NSLog(@"添加字段失败");
        
    }
    
    [STDbHandle closeDb];
}

/**
 *	@brief	根据aClass创建表
 *
 *	@param 	aClass 	表相关类
 */
+ (void)createDbTable:(Class)aClass
{
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    if ([STDbHandle sqlite_tableExist:aClass]) {
        STDBLog(@"数据库表%@已存在!", NSStringFromClass(aClass));
        return;
    }
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"create table "];
    [sql appendString:NSStringFromClass(aClass)];
    [sql appendString:@"("];
    
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    
    [STDbHandle class:aClass getPropertyNameList:propertyArr];
    
    NSString *propertyStr = [propertyArr componentsJoinedByString:@","];
    
    [sql appendString:propertyStr];
    
    [sql appendString:@");"];
    
    STDbHandle *db = [STDbHandle shareDb];
    NSLog(@"create table:%@",sql);
    BOOL result = [db.fmdb executeUpdate:sql];
    
    if (!result) {
        
        NSLog(@"创建表失败");
        
    }
    
    [STDbHandle closeDb];
}

/**
 *	@brief	插入一条数据
 *
 *	@param 	obj 	数据对象
 */
+ (BOOL)insertDbObject:(STDbObject *)obj
{
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    NSString *tableName = NSStringFromClass(obj.class);
    
    if (![STDbHandle sqlite_tableExist:obj.class]) {
        [STDbHandle createDbTable:obj.class];
    }
    
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    propertyArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    unsigned long argNum = [propertyArr count];
    
    NSMutableString *sql_NSString = [[NSMutableString alloc] initWithFormat:@"insert into %@ values(?)", tableName];
    NSRange range = [sql_NSString rangeOfString:@"?"];
    for (int i = 0; i < argNum - 1; i++) {
        [sql_NSString insertString:@",?" atIndex:range.location + 1];
    }

    STDbHandle *db = [STDbHandle shareDb];
    NSMutableArray *column_values = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= argNum; i++) {
        NSString * key = propertyArr[i - 1][@"title"];
        
        if ([key isEqualToString:kDbId]) {
            [column_values addObject:[NSNull null]];
            continue;
        }
        
//      NSString *column_type_string = propertyArr[i - 1][@"type"];
        id value = [obj valueForKey:key];
        [column_values addObject:value];
        
    }
    if ([db.fmdb beginTransaction]) {
        
        BOOL result1 = [db.fmdb executeUpdate:sql_NSString withArgumentsInArray:column_values];
        if (!result1) {
            
            [STDbHandle closeDb];
            return NO;
            
        }
        BOOL result = [db.fmdb commit];
        if (!result) {
            [STDbHandle closeDb];
            return NO;
        }
        [STDbHandle closeDb];
        return YES;
    }

    return NO;

}
+(BOOL)insertDbObjects:(NSArray *)objs{
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }

    STDbHandle *db = [STDbHandle shareDb];
    STDbObject *obj = [objs lastObject];
    NSString *tableName = NSStringFromClass(obj.class);
    
    if (![STDbHandle sqlite_tableExist:obj.class]) {
        [STDbHandle createDbTable:obj.class];
    }
    
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    propertyArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    if ([db.fmdb beginTransaction]) {
        
        for (STDbObject *obj in objs) {

            unsigned long argNum = [propertyArr count];
            
            NSMutableString *sql_NSString = [[NSMutableString alloc] initWithFormat:@"insert into %@ values(?)", tableName];
            NSRange range = [sql_NSString rangeOfString:@"?"];
            
            for (int i = 0; i < argNum - 1; i++) {
                
                [sql_NSString insertString:@",?" atIndex:range.location + 1];
                
            }
            
            NSMutableArray *column_values = [[NSMutableArray alloc] init];
            
            for (int i = 1; i <= argNum; i++) {
                NSString * key = propertyArr[i - 1][@"title"];
                
                if ([key isEqualToString:kDbId]) {
                    
                    [column_values addObject:[NSNull null]];
                    continue;
                }
                
                //      NSString *column_type_string = propertyArr[i - 1][@"type"];
                id value = [obj valueForKey:key];
                [column_values addObject:value];
                
            }
            BOOL result = [db.fmdb executeUpdate:sql_NSString withArgumentsInArray:column_values];
            
            if (!result) {
                [STDbHandle closeDb];
                return NO;
            }
            
        }
        BOOL result = [db.fmdb commit];
        
        if (!result) {
            [STDbHandle closeDb];
            return NO;
        }
        [STDbHandle closeDb];
        return YES;
    }

    return NO;

}
+ (NSMutableArray *)selectDbObjects:(Class)aClass selectValue:(NSString *)_select condition:(NSString *)condition orderby:(NSString *)orderby{
    if (![STDbHandle isOpened]) {
        
        [STDbHandle openDb];
        
    }
    // 清除过期数据
    //    [self cleanExpireDbObject:aClass];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableString *selectstring = nil;
    NSString *tableName = NSStringFromClass(aClass);
    
    selectstring = [[NSMutableString alloc] initWithFormat:@"select %@ from %@", _select, tableName];
    if (condition != nil || [condition length] != 0) {
        if (![[condition lowercaseString] isEqualToString:@"all"]) {
            [selectstring appendFormat:@" where %@", condition];
        }
    }
    if (orderby != nil || [orderby length] != 0) {
        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
            
            [selectstring appendFormat:@" order by %@", orderby];
        }
    }
    
    STDbHandle *db = [STDbHandle shareDb];
    FMResultSet *resultSet = [db.fmdb executeQuery:selectstring];
    
    while ([resultSet next]) {
        
        NSDictionary *resultDic = [resultSet resultDictionary];
        
        
        [array addObject:[resultDic objectForKey:_select]];
        
    }
    
    [STDbHandle closeDb];
    
    return array;

}
/**
 *	@brief	根据条件查询数据
 *
 *	@param 	aClass 	表相关类
 *	@param 	condition 	条件（nil或空或all为无条件），例 id=5 and name='yls'
 *                      带条数限制条件:id=5 and name='yls' limit 5
 *	@param 	orderby 	排序（nil或空或no为不排序）, 例 id,name
 *
 *	@return	数据对象数组
 */
+ (NSMutableArray *)selectDbObjects:(Class)aClass condition:(NSString *)condition orderby:(NSString *)orderby
{
    if (![STDbHandle isOpened]) {
        
        [STDbHandle openDb];
        
    }
    // 清除过期数据
//    [self cleanExpireDbObject:aClass];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableString *selectstring = nil;
    NSString *tableName = NSStringFromClass(aClass);
    
    selectstring = [[NSMutableString alloc] initWithFormat:@"select %@ from %@", @"*", tableName];
    if (condition != nil || [condition length] != 0) {
        if (![[condition lowercaseString] isEqualToString:@"all"]) {
            [selectstring appendFormat:@" where %@", condition];
        }
    }
    if (orderby != nil || [orderby length] != 0) {
        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
            
            [selectstring appendFormat:@" order by %@", orderby];
        }
    }
    
    STDbHandle *db = [STDbHandle shareDb];
    FMResultSet *resultSet = [db.fmdb executeQuery:selectstring];
    
    while ([resultSet next]) {
        
        STDbObject *obj = [[NSClassFromString(tableName) alloc] init];
        
        NSDictionary *resultDic = [resultSet resultDictionary];
        
        [obj toObject:resultDic];
        
        [array addObject:obj];
        
    }
    
    [STDbHandle closeDb];
    
    return array;
}

+(NSMutableArray *)selectDbobjects:(Class)aClass condition:(NSString *)condition orderby:(NSString *)orderby limit:(NSInteger)limit offset:(NSInteger)offset{
    
    if (![STDbHandle isOpened]) {
        
        [STDbHandle openDb];
        
    }
    // 清除过期数据
    //    [self cleanExpireDbObject:aClass];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableString *selectstring = nil;
    NSString *tableName = NSStringFromClass(aClass);
    
    selectstring = [[NSMutableString alloc] initWithFormat:@"select %@ from %@", @"*", tableName];
    if (condition != nil || [condition length] != 0) {
        if (![[condition lowercaseString] isEqualToString:@"all"]) {
            [selectstring appendFormat:@" where %@", condition];
        }
    }
    if (orderby != nil || [orderby length] != 0) {
        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
            
            [selectstring appendFormat:@" order by %@", orderby];
        }
    }
    [selectstring appendFormat:@" limit %ld offset %ld",(long)limit,(long)offset];
    STDbHandle *db = [STDbHandle shareDb];
    FMResultSet *resultSet = [db.fmdb executeQuery:selectstring];
    
    while ([resultSet next]) {
        
        STDbObject *obj = [[NSClassFromString(tableName) alloc] init];
        
        NSDictionary *resultDic = [resultSet resultDictionary];
        
        [obj toObject:resultDic];
        
        [array addObject:obj];
        //        for (int i =0; i < column_count; i++) {
        //
        //            const char *column_name = [resultSet columnNameForIndex:i].UTF8String;
        //            Class className = [obj class];
        //
        //            objc_property_t property_t = class_getProperty(className, column_name);
        //            id column_value = nil;
        //
        //        }
        
    }
    
    [STDbHandle closeDb];
    
    return array;
    
}
/**
 *	@brief	根据条件删除类
 *
 *	@param 	aClass      表相关类
 *	@param 	condition   条件（nil或空为无条件），例 id=5 and name='yls'
 *                      无条件或者all时删除所有.
 *
 *	@return	删除是否成功
 */
+ (BOOL)removeDbObjects:(Class)aClass condition:(NSString *)condition
{
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    sqlite3_stmt *stmt = NULL;
    int rc = -1;
    
    sqlite3 *sqlite3DB = [[STDbHandle shareDb] sqlite3DB];
    
    NSString *tableName = NSStringFromClass(aClass);
    
    // 删掉表
    if (!condition || [[condition lowercaseString] isEqualToString:@"all"]) {
        return [self removeDbTable:aClass];
    }
    
    NSMutableString *createStr;
    
    if ([condition length] > 0) {
        createStr = [NSMutableString stringWithFormat:@"delete from %@ where %@", tableName, condition];
    } else {
        createStr = [NSMutableString stringWithFormat:@"delete from %@", tableName];
    }
    
    NSLog(@"%@",createStr);
    const char *errmsg = 0;
    if (sqlite3_prepare_v2(sqlite3DB, [createStr UTF8String], -1, &stmt, &errmsg) == SQLITE_OK) {
        rc = sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
    [STDbHandle closeDb];
    if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
        fprintf(stderr,"remove dbObject fail: %s\n",errmsg);
        return NO;
    }
    return YES;
}

/**
 *	@brief	根据条件修改一条数据
 *
 *	@param 	obj 	修改的数据对象（属性中有值的修改，为nil的不处理）
 *	@param 	condition 	条件（nil或空为无条件），例 id=5 and name='yls'
 *
 *	@return	修改是否成功
 */
+ (BOOL)updateDbObject:(STDbObject *)obj condition:(NSString *)condition
{
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    STDbHandle *db = [STDbHandle shareDb];
//    NSMutableArray *propertyTypeArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    NSString *tableName = NSStringFromClass(obj.class);
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];

    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(obj.class, &count);
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id objValue = [obj valueForKey:key];
        id value = [self valueForDbObjc_property_t:property dbValue:objValue];

        if (value && (NSNull *)value != [NSNull null]) {
            NSString *bindValue = [NSString stringWithFormat:@"%@=?", key];
            [propertyArr addObject:bindValue];
            [keys addObject:key];
        }
    }
    
    NSString *newValue = [propertyArr componentsJoinedByString:@","];
    
    NSMutableString *createStr = [NSMutableString stringWithFormat:@"update %@ set %@ where %@", tableName, newValue, condition];
    NSMutableArray *column_values = [[NSMutableArray alloc] init];
    
//    NSLog(@"更新数据库语句:%@",createStr);
    for (NSString *key in keys) {
        
        if ([key isEqualToString:kDbId]) {
            [column_values addObject:[NSNull null]];
            continue;
        }
        
        id value = [obj valueForKeyPath:key];
        [column_values addObject:value];
        
    }
    BOOL result = [db.fmdb executeUpdate:createStr withArgumentsInArray:column_values];
    
    [STDbHandle closeDb];
    if (!result) {
        return NO;
    }
    return YES;
    
}

+(BOOL)updateDbObjects:(NSArray *)objs {
    
    
    
    sqlite3 *sqlite3DB = [[STDbHandle shareDb] sqlite3DB];
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
        
    }
    
    
    char *errorMsg;
    
    if (sqlite3_exec(sqlite3DB, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, &errorMsg) != SQLITE_OK){
        return NO;
    }
        
        for (STDbObject *obj in objs) {
            NSMutableArray *propertyTypeArr = [NSMutableArray arrayWithArray:[self sqlite_columns:obj.class]];
            
            sqlite3_stmt *stmt = NULL;
            
            int rc = -1;
            NSString *tableName = NSStringFromClass(obj.class);
            NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(obj.class, &count);
            NSMutableArray *keys = [NSMutableArray arrayWithCapacity:0];
            NSString *condition = @"";
            for (int i = 0; i < count; i++) {
                objc_property_t property = properties[i];
                NSString * key = [[NSString alloc]initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                id objValue = [obj valueForKey:key];
                id value = [self valueForDbObjc_property_t:property dbValue:objValue];
                
                if (value && (NSNull *)value != [NSNull null]) {
                    NSString *bindValue = [NSString stringWithFormat:@"%@=?", key];
                    [propertyArr addObject:bindValue];
                    [keys addObject:key];
                }
            }
            
            NSString *newValue = [propertyArr componentsJoinedByString:@","];
            
            NSMutableString *createStr = [NSMutableString stringWithFormat:@"update %@ set %@ where %@", tableName, newValue, condition];
            
            const char *errmsg = 0;
            
            NSLog(@"%d",sqlite3_prepare_v2(sqlite3DB, [createStr UTF8String], -1, &stmt, &errmsg));
            if (sqlite3_prepare_v2(sqlite3DB, [createStr UTF8String], -1, &stmt, &errmsg) == SQLITE_OK) {
                
                NSInteger i = 1;
                for (NSString *key in keys) {
                    
                    if ([key isEqualToString:kDbId]) {
                        continue;
                    }
                    
                    NSString *column_type_string = propertyTypeArr[i - 1][@"type"];
                    
                    id value = [obj valueForKey:key];
                    //            NSLog(@"value:%@",value);
                    if ([column_type_string isEqualToString:@"blob"]) {
                        if (!value || value == [NSNull null] || [value isEqual:@""]) {
                            sqlite3_bind_null(stmt, i);
                        } else {
                            NSData *data = [NSData dataWithData:value];
                            long len = [data length];
                            const void *bytes = [data bytes];
                            sqlite3_bind_blob(stmt, i, bytes, len, NULL);
                        }
                        
                    } else if ([column_type_string isEqualToString:@"text"]) {
                        //                NSString *str = [NSString stringWithFormat:@"%@",value];
                        if (!value || value == [NSNull null] || [value isEqual:@""]) {
                            sqlite3_bind_null(stmt, i);
                        } else {
                            objc_property_t property_t = class_getProperty(obj.class, [key UTF8String]);
                            
                            value = [self valueForDbObjc_property_t:property_t dbValue:value];
                            NSString *column_value = [NSString stringWithFormat:@"%@", value];
                            sqlite3_bind_text(stmt, i, [column_value UTF8String], -1, SQLITE_STATIC);
                        }
                        
                    } else if ([column_type_string isEqualToString:@"real"]) {
                        if (!value || value == [NSNull null] || [value isEqual:@""]) {
                            sqlite3_bind_null(stmt, i);
                        } else {
                            id column_value = value;
                            sqlite3_bind_double(stmt, i, [column_value doubleValue]);
                        }
                    }
                    else if ([column_type_string isEqualToString:@"integer"]) {
                        if (!value || value == [NSNull null] || [value isEqual:@""]) {
                            sqlite3_bind_null(stmt, i);
                        } else {
                            id column_value = value;
                            sqlite3_bind_int(stmt, i, [column_value intValue]);
                        }
                    }
                    i++;
                }
                
                rc = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
            stmt = NULL;
            if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
                fprintf(stderr,"update table fail: %s\n",errmsg);
                return NO;
            }
        }
        
        sqlite3_exec(sqlite3DB, "COMMIT", 0, 0, &errorMsg);
        
        
        [STDbHandle closeDb];
        return YES;
}
/**
 *	@brief	根据aClass删除表
 *
 *	@param 	aClass 	表相关类
 *
 *	@return	删除表是否成功
 */
+ (BOOL)removeDbTable:(Class)aClass
{
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"drop table if exists "];
    [sql appendString:NSStringFromClass(aClass)];

    char *errmsg = 0;
    STDbHandle *db = [STDbHandle shareDb];
    sqlite3 *sqlite3DB = db.sqlite3DB;
    int ret = sqlite3_exec(sqlite3DB,[sql UTF8String], NULL, NULL, &errmsg);
    if(ret != SQLITE_OK){
        fprintf(stderr,"drop table fail: %s\n",errmsg);
    }
    sqlite3_free(errmsg);
    
    [STDbHandle closeDb];
    
    return YES;
}

///**
// *	@brief	根据aClass清除过期数据
// *
// *	@param 	aClass 	表相关类
// *
// *	@return	清除过期表是否成功
// */
//+ (BOOL)cleanExpireDbObject:(Class)aClass
//{
//    if (![STDbHandle isOpened]) {
//        [STDbHandle openDb];
//    }
//
//    NSString *dateStr = [NSDate stringWithDate:[NSDate date]];
//    NSString *condition = [NSString stringWithFormat:@"expireDate<'%@'", dateStr];
//    [self removeDbObjects:aClass condition:condition];
//    
//    if (![STDbHandle isOpened]) {
//        [STDbHandle openDb];
//    }
//    
//    return YES;
//}

#pragma mark - other method

/*
 * 查看所有表名
 */
+ (NSArray *)sqlite_tablename {
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    NSMutableArray *tablenameArray = [[NSMutableArray alloc] init];
    NSString *str = [NSString stringWithFormat:@"select tbl_name from sqlite_master where type='table'"];
    FMDatabase *fmdb = [STDbHandle shareDb].fmdb;
    
    FMResultSet *resultSet = [fmdb executeQuery:str];
    while (resultSet.next) {
        const unsigned char *text = (const unsigned char *)([resultSet stringForColumnIndex:0].UTF8String);
        [tablenameArray addObject:[NSString stringWithUTF8String:(const char *)text]];
    }
    
    [STDbHandle closeDb];
    
    return tablenameArray;
}

/*
 * 判断一个表是否存在；
 */
+ (BOOL)sqlite_tableExist:(Class)aClass {
    NSArray *tableArray = [self sqlite_tablename];
    NSString *tableName = NSStringFromClass(aClass);
    for (NSString *tablename in tableArray) {
        if ([tablename isEqualToString:tableName]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)sqlite_columns:(Class)cls
{
    NSString *table = NSStringFromClass(cls);
    NSMutableString *sql;
    
    NSString *str = [NSString stringWithFormat:@"select sql from sqlite_master where type='table' and tbl_name='%@'", table];
    STDbHandle *stdb = [STDbHandle shareDb];
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    
    FMResultSet *resultSet = [stdb.fmdb executeQuery:str];
    
    while (resultSet.next) {
        
        const unsigned char *text = (const unsigned char *)([resultSet stringForColumnIndex:0].UTF8String);
        sql = [NSMutableString stringWithUTF8String:(const char *)text];
        
    }
    
    NSRange r = [sql rangeOfString:@"("];
    
    NSString *t_str = [sql substringWithRange:NSMakeRange(r.location + 1, [sql length] - r.location - 2)];
    t_str = [t_str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    t_str = [t_str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    t_str = [t_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray *colsArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *s in [t_str componentsSeparatedByString:@","]) {
        NSString *s0 = [NSString stringWithString:s];
        s0 = [s0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *a = [s0 componentsSeparatedByString:@" "];
        NSString *s1 = a[0];
        NSString *type = a.count >= 2 ? a[1] : @"blob";
        type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        type = [type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        s1 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [colsArr addObject:@{@"type": type, @"title": s1}];
    }
    return colsArr;
}

+ (NSString *)dbTypeConvertFromObjc_property_t:(objc_property_t)property
{
//    NSString * attr = [[NSString alloc]initWithCString:property_getAttributes(property)  encoding:NSUTF8StringEncoding];
    char * type = property_copyAttributeValue(property, "T");
    
    switch(type[0]) {
        case 'f' : //float
        case 'd' : //double
        {
            return DBFloat;
        }
            break;
        
        case 'c':   // char
        case 's' : //short
        case 'i':   // int
        case 'l':   // long
        {
            return DBInt;
        }
            break;

        case '*':   // char *
            break;
            
        case '@' : //ObjC object
            //Handle different clases in here
        {
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                return DBText;
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                return DBText;
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                return DBText;
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                return DBText;
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                return DBText;
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSData class]]) {
                return DBData;
            }
        }
            break;
    }

    return DBText;
}

+ (id)valueForObjc_property_t:(objc_property_t)property dbValue:(id)dbValue
{
    char * type = property_copyAttributeValue(property, "T");
    if (type) {
        
        switch(type[0]) {
            case 'f' : //float
            {
                return [NSNumber numberWithDouble:[dbValue floatValue]];
            }
                break;
            case 'd' : //double
            {
                return [NSNumber numberWithDouble:[dbValue doubleValue]];
            }
                break;
                
            case 'c':   // char
            {
                return [NSNumber numberWithDouble:[dbValue charValue]];
            }
                break;
            case 's' : //short
            {
                return [NSNumber numberWithDouble:[dbValue shortValue]];
            }
                break;
            case 'i':   // int
            {
                return [NSNumber numberWithDouble:[dbValue longValue]];
            }
                break;
            case 'l':   // long
            {
                return [NSNumber numberWithDouble:[dbValue longValue]];
            }
                break;
                
            case '*':   // char *
                break;
                
            case '@' : //ObjC object
                //Handle different clases in here
            {
                NSString *cls = [NSString stringWithUTF8String:type];
                cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
                cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                    return [NSString  stringWithFormat:@"%@", dbValue];
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                    return [NSNumber numberWithDouble:[dbValue doubleValue]];
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                    return [NSDictionary objectWithString:[NSString stringWithFormat:@"%@", dbValue]];
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                    return [NSArray objectWithString:[NSString stringWithFormat:@"%@", dbValue]];
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                    return [NSDate dateWithString:[NSString stringWithFormat:@"%@", dbValue]];
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSValue class]]) {
                    return [NSData dataWithData:dbValue];
                }
            }
                break;
        }
        
    }

    return dbValue;
}

+ (id)valueForDbObjc_property_t:(objc_property_t)property dbValue:(id)dbValue
{
    char * type = property_copyAttributeValue(property, "T");
    
    switch(type[0]) {
        case 'f' : //float
        {
            return [NSNumber numberWithDouble:[dbValue floatValue]];
        }
            break;
        case 'd' : //double
        {
            return [NSNumber numberWithDouble:[dbValue doubleValue]];
        }
            break;
            
        case 'c':   // char
        {
            return [NSNumber numberWithDouble:[dbValue charValue]];
        }
            break;
        case 's' : //short
        {
            return [NSNumber numberWithDouble:[dbValue shortValue]];
        }
            break;
        case 'i':   // int
        {
            return [NSNumber numberWithDouble:[dbValue longValue]];
        }
            break;
        case 'l':   // long
        {
            return [NSNumber numberWithDouble:[dbValue longValue]];
        }
            break;
            
        case '*':   // char *
            break;
            
        case '@' : //ObjC object
            //Handle different clases in here
        {
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                return [NSString  stringWithFormat:@"%@", dbValue];
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                return [NSNumber numberWithDouble:[dbValue doubleValue]];
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                return [NSDictionary stringWithObject:dbValue];
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                return [NSDictionary stringWithObject:dbValue];
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                if ([dbValue isKindOfClass:[NSDate class]]) {
                    return [NSString stringWithFormat:@"%@", [NSDate stringWithDate:dbValue]];
                } else {
                    return @"";
                }
                
            }
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSValue class]]) {
                return [NSData dataWithData:dbValue];
            }
        }
            break;
    }
    
    return dbValue;
}

+ (BOOL)isOpened
{
    return [[self shareDb] isOpened];
}

+ (void)class:(Class)aClass getPropertyNameList:(NSMutableArray *)proName
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        NSString *type = [STDbHandle dbTypeConvertFromObjc_property_t:property];
        
        NSString *proStr;
        if ([key isEqualToString:kDbId]) {
            proStr = [NSString stringWithFormat:@"%@ %@ primary key AUTOINCREMENT", kDbId, DBInt];
        } else {
            proStr = [NSString stringWithFormat:@"%@ %@", key, type];
        }

        [proName addObject:proStr];
    }
    
    if (aClass == [STDbObject class]) {
        return;
    }
    [STDbHandle class:[aClass superclass] getPropertyNameList:proName];
}

+ (void)class:(Class)aClass getPropertyKeyList:(NSMutableArray *)proName
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        [proName addObject:key];
    }
    
    if (aClass == [STDbObject class]) {
        return;
    }
    [STDbHandle class:[aClass superclass] getPropertyKeyList:proName];
}

+ (void)class:(Class)aClass getPropertyTypeList:(NSMutableArray *)proName
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *type = [STDbHandle dbTypeConvertFromObjc_property_t:property];
        [proName addObject:type];
    }
    
    if (aClass == [STDbObject class]) {
        return;
    }
    [STDbHandle class:[aClass superclass] getPropertyTypeList:proName];
}

+(NSDictionary *)executeQuery:(NSString *)sql{
    
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    
    STDbHandle *db = [STDbHandle shareDb];
    
    FMResultSet *resultSet = [db.fmdb executeQuery:sql];
    NSDictionary *totalAndDateDic;
    NSMutableArray *totalMoney = [[NSMutableArray alloc] init];
    NSMutableArray *moneyDate = [[NSMutableArray alloc] init];
    
    while ([resultSet next]) {
        
        NSString *total = [resultSet stringForColumn:@"total"];
        NSString *date = [resultSet stringForColumn:@"date"];
        
        [totalMoney addObject:total];
        [moneyDate addObject:date];
    }
    totalAndDateDic = [NSDictionary dictionaryWithObjects:totalMoney forKeys:moneyDate];
    [STDbHandle closeDb];
    return totalAndDateDic;
    
    
    
}
//+(NSArray *)executeQuery:(NSString *)sql Where:(NSString *)where orderby:(NSString *)orderby limit:(NSInteger)limit offset:(NSInteger)offset{
//    
//    if (![STDbHandle isOpened]) {
//        [STDbHandle openDb];
//    }
//    NSMutableString *selectstring = [NSMutableString stringWithString:sql];
//    
//    STDbHandle *db = [STDbHandle shareDb];
//    
//    if (where != nil || [where length] != 0) {
//        if (![[where lowercaseString] isEqualToString:@"all"]) {
//            [selectstring appendFormat:@" where %@", where];
//        }
//    }
//    if (orderby != nil || [orderby length] != 0) {
//        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
//            
//            [selectstring appendFormat:@" order by %@", orderby];
//        }
//    }
//    if (limit>0&&offset>=0) {
//        [selectstring appendFormat:@" limit %ld offset %ld",(long)limit,(long)offset];
//    }
//    
//    NSLog(@"selectstring is :%@",selectstring);
//    FMResultSet *resultSet = [db.fmdb executeQuery:selectstring];
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    while ([resultSet next]) {
//        
//        Trade *obj = [[Trade alloc] init];
//        
//        NSDictionary *resultDic = [resultSet resultDictionary];
//        [obj toObject:resultDic];
////        obj.date = [resultSet stringForColumn:@"date"];
//        [array addObject:obj];
//        
//    }
//    
//    [STDbHandle closeDb];
//    
//    return array;
//}
+(NSString *)getAverage:(NSString *)sql{
    
    NSString *avgStr;
    if (![STDbHandle isOpened]) {
        [STDbHandle openDb];
    }
    STDbHandle *db = [STDbHandle shareDb];
    FMResultSet *resutltSet = [db.fmdb executeQuery:sql];
    while ([resutltSet next]) {
        
        avgStr = [resutltSet stringForColumn:@"average"];
        
    }
    [STDbHandle closeDb];
    return avgStr;
}
@end




