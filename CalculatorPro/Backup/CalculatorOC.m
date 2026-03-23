//
//  CalculatorOC.m
//  CalculatorPro
//
//  Objective-C 计算器核心实现
//

#import "CalculatorOC.h"
#import <math.h>

@interface CalculatorOC ()
@property (nonatomic, assign) double memoryValue;
@end

@implementation CalculatorOC

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryValue = 0.0;
    }
    return self;
}

#pragma mark - 基本计算操作

- (double)add:(double)a to:(double)b {
    return a + b;
}

- (double)subtract:(double)a from:(double)b {
    return b - a;
}

- (double)multiply:(double)a by:(double)b {
    return a * b;
}

- (double)divide:(double)a by:(double)b {
    if (b == 0) {
        return NAN; // 返回非数字表示除以零错误
    }
    return a / b;
}

- (double)percentage:(double)value of:(double)total {
    if (total == 0) {
        return 0;
    }
    return (value / total) * 100;
}

#pragma mark - 高级计算

- (double)squareRoot:(double)value {
    if (value < 0) {
        return NAN;
    }
    return sqrt(value);
}

- (double)power:(double)base exponent:(double)exponent {
    return pow(base, exponent);
}

- (double)sin:(double)angle {
    return sin(angle * M_PI / 180.0); // 转换为弧度
}

- (double)cos:(double)angle {
    return cos(angle * M_PI / 180.0); // 转换为弧度
}

- (double)tan:(double)angle {
    return tan(angle * M_PI / 180.0); // 转换为弧度
}

#pragma mark - 内存功能

- (void)memoryStore:(double)value {
    self.memoryValue = value;
}

- (double)memoryRecall {
    return self.memoryValue;
}

- (void)memoryClear {
    self.memoryValue = 0.0;
}

- (void)memoryAdd:(double)value {
    self.memoryValue += value;
}

- (void)memorySubtract:(double)value {
    self.memoryValue -= value;
}

#pragma mark - 表达式计算

- (double)evaluateExpression:(NSString *)expression error:(NSError **)error {
    // 简单的表达式求值实现
    // 注意：这是一个简化版本，实际应用中应该使用更强大的表达式解析器
    
    @try {
        NSExpression *expr = [NSExpression expressionWithFormat:expression];
        id result = [expr expressionValueWithObject:nil context:nil];
        
        if ([result isKindOfClass:[NSNumber class]]) {
            return [result doubleValue];
        } else {
            if (error) {
                *error = [NSError errorWithDomain:@"CalculatorErrorDomain"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"无效的表达式结果"}];
            }
            return NAN;
        }
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"CalculatorErrorDomain"
                                         code:1002
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"表达式求值失败"}];
        }
        return NAN;
    }
}

#pragma mark - 格式化

- (NSString *)formatNumber:(double)number {
    return [self formatNumber:number withDecimalPlaces:10];
}

- (NSString *)formatNumber:(double)number withDecimalPlaces:(NSInteger)decimalPlaces {
    if (isnan(number)) {
        return @"错误";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = decimalPlaces;
    formatter.minimumFractionDigits = 0;
    formatter.groupingSeparator = @"";
    
    return [formatter stringFromNumber:@(number)] ?: @"";
}

#pragma mark - 单位转换

// 简化的单位转换实现
// 实际应用中应该使用更精确的转换率和实时汇率

- (double)convertCurrency:(double)amount from:(NSString *)fromCurrency to:(NSString *)toCurrency {
    // 简化的汇率转换（示例汇率）
    NSDictionary *exchangeRates = @{
        @"USD": @1.0,
        @"EUR": @0.85,
        @"GBP": @0.73,
        @"JPY": @110.0,
        @"CNY": @6.45
    };
    
    NSNumber *fromRate = exchangeRates[fromCurrency.uppercaseString];
    NSNumber *toRate = exchangeRates[toCurrency.uppercaseString];
    
    if (!fromRate || !toRate) {
        return NAN;
    }
    
    // 转换为美元，再转换为目标货币
    double usdAmount = amount / [fromRate doubleValue];
    return usdAmount * [toRate doubleValue];
}

- (double)convertLength:(double)length from:(NSString *)fromUnit to:(NSString *)toUnit {
    // 长度单位转换
    NSDictionary *conversionFactors = @{
        @"m": @1.0,
        @"km": @1000.0,
        @"cm": @0.01,
        @"mm": @0.001,
        @"in": @0.0254,
        @"ft": @0.3048,
        @"yd": @0.9144,
        @"mi": @1609.34
    };
    
    NSNumber *fromFactor = conversionFactors[fromUnit.lowercaseString];
    NSNumber *toFactor = conversionFactors[toUnit.lowercaseString];
    
    if (!fromFactor || !toFactor) {
        return NAN;
    }
    
    // 转换为米，再转换为目标单位
    double meters = length * [fromFactor doubleValue];
    return meters / [toFactor doubleValue];
}

- (double)convertWeight:(double)weight from:(NSString *)fromUnit to:(NSString *)toUnit {
    // 重量单位转换
    NSDictionary *conversionFactors = @{
        @"kg": @1.0,
        @"g": @0.001,
        @"mg": @0.000001,
        @"lb": @0.453592,
        @"oz": @0.0283495
    };
    
    NSNumber *fromFactor = conversionFactors[fromUnit.lowercaseString];
    NSNumber *toFactor = conversionFactors[toUnit.lowercaseString];
    
    if (!fromFactor || !toFactor) {
        return NAN;
    }
    
    // 转换为千克，再转换为目标单位
    double kilograms = weight * [fromFactor doubleValue];
    return kilograms / [toFactor doubleValue];
}

@end