//
//  CalculatorOC.h
//  CalculatorPro
//
//  Objective-C 计算器核心类
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalculatorOC : NSObject

// 基本计算操作
- (double)add:(double)a to:(double)b;
- (double)subtract:(double)a from:(double)b;
- (double)multiply:(double)a by:(double)b;
- (double)divide:(double)a by:(double)b;
- (double)percentage:(double)value of:(double)total;

// 高级计算
- (double)squareRoot:(double)value;
- (double)power:(double)base exponent:(double)exponent;
- (double)sin:(double)angle;
- (double)cos:(double)angle;
- (double)tan:(double)angle;

// 内存功能
- (void)memoryStore:(double)value;
- (double)memoryRecall;
- (void)memoryClear;
- (void)memoryAdd:(double)value;
- (void)memorySubtract:(double)value;

// 表达式计算
- (double)evaluateExpression:(NSString *)expression error:(NSError **)error;

// 格式化
- (NSString *)formatNumber:(double)number;
- (NSString *)formatNumber:(double)number withDecimalPlaces:(NSInteger)decimalPlaces;

// 单位转换
- (double)convertCurrency:(double)amount from:(NSString *)fromCurrency to:(NSString *)toCurrency;
- (double)convertLength:(double)length from:(NSString *)fromUnit to:(NSString *)toUnit;
- (double)convertWeight:(double)weight from:(NSString *)fromUnit to:(NSString *)toUnit;

@end

NS_ASSUME_NONNULL_END