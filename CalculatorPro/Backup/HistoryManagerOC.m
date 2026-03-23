//
//  HistoryManagerOC.m
//  CalculatorPro
//
//  Objective-C 历史记录管理器实现
//

#import "HistoryManagerOC.h"

@implementation HistoryItemOC

- (instancetype)initWithExpression:(NSString *)expression result:(NSString *)result {
    return [self initWithExpression:expression result:result category:@"general"];
}

- (instancetype)initWithExpression:(NSString *)expression result:(NSString *)result category:(NSString *)category {
    self = [super init];
    if (self) {
        _expression = [expression copy];
        _result = [result copy];
        _timestamp = [NSDate date];
        _category = [category copy] ?: @"general";
    }
    return self;
}

- (NSString *)displayText {
    return [NSString stringWithFormat:@"%@ = %@", self.expression, self.result];
}

- (NSDictionary *)toDictionary {
    return @{
        @"expression": self.expression ?: @"",
        @"result": self.result ?: @"",
        @"timestamp": self.timestamp ?: [NSDate date],
        @"category": self.category ?: @"general"
    };
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _expression = [coder decodeObjectForKey:@"expression"];
        _result = [coder decodeObjectForKey:@"result"];
        _timestamp = [coder decodeObjectForKey:@"timestamp"];
        _category = [coder decodeObjectForKey:@"category"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.expression forKey:@"expression"];
    [coder encodeObject:self.result forKey:@"result"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.category forKey:@"category"];
}

@end

@interface HistoryManagerOC ()
@property (nonatomic, strong) NSMutableArray<HistoryItemOC *> *mutableHistoryItems;
@end

@implementation HistoryManagerOC

- (instancetype)init {
    return [self initWithMaxHistoryCount:100];
}

- (instancetype)initWithMaxHistoryCount:(NSInteger)maxCount {
    self = [super init];
    if (self) {
        _mutableHistoryItems = [NSMutableArray array];
        _maxHistoryCount = maxCount;
    }
    return self;
}

#pragma mark - 历史记录管理

- (NSArray<HistoryItemOC *> *)historyItems {
    return [self.mutableHistoryItems copy];
}

- (void)addHistoryItem:(HistoryItemOC *)item {
    if (!item) return;
    
    [self.mutableHistoryItems insertObject:item atIndex:0];
    
    // 如果超过最大数量，移除最旧的记录
    if (self.mutableHistoryItems.count > self.maxHistoryCount) {
        [self.mutableHistoryItems removeLastObject];
    }
}

- (void)addHistoryWithExpression:(NSString *)expression result:(NSString *)result {
    HistoryItemOC *item = [[HistoryItemOC alloc] initWithExpression:expression result:result];
    [self addHistoryItem:item];
}

- (void)addHistoryWithExpression:(NSString *)expression result:(NSString *)result category:(NSString *)category {
    HistoryItemOC *item = [[HistoryItemOC alloc] initWithExpression:expression result:result category:category];
    [self addHistoryItem:item];
}

- (void)removeHistoryItemAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.mutableHistoryItems.count) {
        [self.mutableHistoryItems removeObjectAtIndex:index];
    }
}

- (void)clearAllHistory {
    [self.mutableHistoryItems removeAllObjects];
}

- (void)removeHistoryItemsBeforeDate:(NSDate *)date {
    if (!date) return;
    
    NSMutableArray *itemsToRemove = [NSMutableArray array];
    for (HistoryItemOC *item in self.mutableHistoryItems) {
        if ([item.timestamp compare:date] == NSOrderedAscending) {
            [itemsToRemove addObject:item];
        }
    }
    
    [self.mutableHistoryItems removeObjectsInArray:itemsToRemove];
}

#pragma mark - 查询

- (NSArray<HistoryItemOC *> *)historyItemsForCategory:(NSString *)category {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    return [self.mutableHistoryItems filteredArrayUsingPredicate:predicate];
}

- (NSArray<HistoryItemOC *> *)historyItemsContainingText:(NSString *)text {
    if (!text || text.length == 0) {
        return @[];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expression CONTAINS[cd] %@ OR result CONTAINS[cd] %@", text, text];
    return [self.mutableHistoryItems filteredArrayUsingPredicate:predicate];
}

- (NSArray<HistoryItemOC *> *)historyItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    if (!fromDate || !toDate) {
        return @[];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ AND timestamp <= %@", fromDate, toDate];
    return [self.mutableHistoryItems filteredArrayUsingPredicate:predicate];
}

#pragma mark - 持久化

- (BOOL)saveHistoryToFile:(NSString *)filePath {
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.mutableHistoryItems requiringSecureCoding:NO error:nil];
        return [data writeToFile:filePath atomically:YES];
    } @catch (NSException *exception) {
        NSLog(@"保存历史记录到文件失败: %@", exception);
        return NO;
    }
}

- (BOOL)loadHistoryFromFile:(NSString *)filePath {
    @try {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (!data) return NO;
        
        NSArray *items = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[NSArray.class, HistoryItemOC.class, NSString.class, NSDate.class]]
                                                             fromData:data error:nil];
        if (items) {
            self.mutableHistoryItems = [items mutableCopy];
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        NSLog(@"从文件加载历史记录失败: %@", exception);
        return NO;
    }
}

- (BOOL)saveHistoryToUserDefaultsWithKey:(NSString *)key {
    return [self saveHistoryToFile:[self userDefaultsFilePathForKey:key]];
}

- (BOOL)loadHistoryFromUserDefaultsWithKey:(NSString *)key {
    return [self loadHistoryFromFile:[self userDefaultsFilePathForKey:key]];
}

- (NSString *)userDefaultsFilePathForKey:(NSString *)key {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.history", key]];
}

#pragma mark - 导出导入

- (BOOL)exportHistoryToCSV:(NSString *)filePath {
    @try {
        NSMutableString *csvContent = [NSMutableString stringWithString:@"Expression,Result,Timestamp,Category\n"];
        
        for (HistoryItemOC *item in self.mutableHistoryItems) {
            NSString *escapedExpression = [self escapeCSVField:item.expression];
            NSString *escapedResult = [self escapeCSVField:item.result];
            NSString *timestamp = [self dateToString:item.timestamp];
            NSString *escapedCategory = [self escapeCSVField:item.category];
            
            [csvContent appendFormat:@"%@,%@,%@,%@\n", escapedExpression, escapedResult, timestamp, escapedCategory];
        }
        
        return [csvContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } @catch (NSException *exception) {
        NSLog(@"导出CSV失败: %@", exception);
        return NO;
    }
}

- (BOOL)importHistoryFromCSV:(NSString *)filePath {
    // 简化的CSV导入实现
    // 实际应用中应该使用更健壮的CSV解析器
    NSLog(@"CSV导入功能需要更完整的实现");
    return NO;
}

- (NSString *)exportHistoryToJSONString {
    @try {
        NSMutableArray *historyArray = [NSMutableArray array];
        
        for (HistoryItemOC *item in self.mutableHistoryItems) {
            [historyArray addObject:[item toDictionary]];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:historyArray options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        NSLog(@"导出JSON失败: %@", exception);
        return @"";
    }
}

- (BOOL)importHistoryFromJSONString:(NSString *)jsonString {
    @try {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *historyArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        if (![historyArray isKindOfClass:[NSArray class]]) {
            return NO;
        }
        
        NSMutableArray *newItems = [NSMutableArray array];
        for (NSDictionary *dict in historyArray) {
            HistoryItemOC *item = [[HistoryItemOC alloc] initWithExpression:dict[@"expression"]
                                                                     result:dict[@"result"]
                                                                   category:dict[@"category"]];
            [newItems addObject:item];
        }
        
        [self.mutableHistoryItems addObjectsFromArray:newItems];
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"导入JSON失败: %@", exception);
        return NO;
    }
}

#pragma mark - 统计

- (NSInteger)totalHistoryCount {
    return self.mutableHistoryItems.count;
}

- (NSInteger)historyCountForCategory:(NSString *)category {
    return [self historyItemsForCategory:category].count;
}

- (NSDictionary<NSString *, NSNumber *> *)categoryStatistics {
    NSMutableDictionary *stats = [NSMutableDictionary dictionary];
    
    for (HistoryItemOC *item in self.mutableHistoryItems) {
        NSString *category = item.category ?: @"general";
        NSNumber *count = stats[category] ?: @0;
        stats[category] = @(count.integerValue + 1);
    }
    
    return [stats copy];
}

- (NSDate *)oldestHistoryDate {
    return [self.mutableHistoryItems lastObject].timestamp;
}

- (NSDate *)newestHistoryDate {
    return [self.mutableHistoryItems firstObject].timestamp;
}

#pragma mark - 工具方法

- (NSString *)escapeCSVField:(NSString *)field {
    if (!field) return @"";
    
    // 如果字段包含逗号、引号或换行符，用引号括起来并转义引号
    if ([field containsString:@","] || [field containsString:@"\""] || [field containsString:@"\n"]) {
        NSString *escaped = [field stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        return [NSString stringWithFormat:@"\"%@\"", escaped];
    }
    
    return field;
}

- (NSString *)dateToString:(NSDate *)date {
    if (!date) return @"";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    
    return [formatter stringFromDate:date];
}

@end