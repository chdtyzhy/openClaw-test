//
//  HistoryManagerOC.h
//  CalculatorPro
//
//  Objective-C 历史记录管理器
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryItemOC : NSObject <NSCoding>

@property (nonatomic, copy) NSString *expression;
@property (nonatomic, copy) NSString *result;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, copy) NSString *category; // 可选：计算类型分类

- (instancetype)initWithExpression:(NSString *)expression result:(NSString *)result;
- (instancetype)initWithExpression:(NSString *)expression result:(NSString *)result category:(NSString *)category;

- (NSString *)displayText;
- (NSDictionary *)toDictionary;

@end

@interface HistoryManagerOC : NSObject

@property (nonatomic, strong, readonly) NSArray<HistoryItemOC *> *historyItems;
@property (nonatomic, assign) NSInteger maxHistoryCount;

- (instancetype)initWithMaxHistoryCount:(NSInteger)maxCount;

// 历史记录管理
- (void)addHistoryItem:(HistoryItemOC *)item;
- (void)addHistoryWithExpression:(NSString *)expression result:(NSString *)result;
- (void)addHistoryWithExpression:(NSString *)expression result:(NSString *)result category:(NSString *)category;

- (void)removeHistoryItemAtIndex:(NSInteger)index;
- (void)clearAllHistory;
- (void)removeHistoryItemsBeforeDate:(NSDate *)date;

// 查询
- (NSArray<HistoryItemOC *> *)historyItemsForCategory:(NSString *)category;
- (NSArray<HistoryItemOC *> *)historyItemsContainingText:(NSString *)text;
- (NSArray<HistoryItemOC *> *)historyItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

// 持久化
- (BOOL)saveHistoryToFile:(NSString *)filePath;
- (BOOL)loadHistoryFromFile:(NSString *)filePath;
- (BOOL)saveHistoryToUserDefaultsWithKey:(NSString *)key;
- (BOOL)loadHistoryFromUserDefaultsWithKey:(NSString *)key;

// 导出导入
- (BOOL)exportHistoryToCSV:(NSString *)filePath;
- (BOOL)importHistoryFromCSV:(NSString *)filePath;
- (NSString *)exportHistoryToJSONString;
- (BOOL)importHistoryFromJSONString:(NSString *)jsonString;

// 统计
- (NSInteger)totalHistoryCount;
- (NSInteger)historyCountForCategory:(NSString *)category;
- (NSDictionary<NSString *, NSNumber *> *)categoryStatistics;
- (NSDate *)oldestHistoryDate;
- (NSDate *)newestHistoryDate;

@end

NS_ASSUME_NONNULL_END