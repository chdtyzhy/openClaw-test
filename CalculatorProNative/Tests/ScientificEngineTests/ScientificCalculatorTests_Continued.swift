import Testing
import ScientificEngine

@testable import ScientificEngine

struct ScientificCalculatorTestsContinued {
    
    // MARK: - 常数测试（续）
    
    @Test func testConstants() {
        let calculator = ScientificCalculator()
        
        // π 值测试
        let pi = calculator.pi
        #expect(pi == Double.pi, accuracy: 1e-15)
        
        // e 值测试
        let e = calculator.e
        #expect(e == M_E, accuracy: 1e-15)
        
        // 黄金比例 φ 测试
        let phi = calculator.goldenRatio
        let expectedPhi = (1.0 + sqrt(5.0)) / 2.0
        #expect(phi == expectedPhi, accuracy: 1e-15)
    }
    
    // MARK: - 缓存测试
    
    @Test func testCalculationCache() throws {
        let calculator = ScientificCalculator()
        calculator.clearCache()
        
        // 第一次计算应该执行实际计算
        let result1 = try calculator.calculateWithCache(function: "sin", value: 30)
        #expect(result1 == 0.5, accuracy: 1e-10)
        
        // 第二次相同计算应该从缓存获取
        let result2 = try calculator.calculateWithCache(function: "sin", value: 30)
        #expect(result2 == 0.5, accuracy: 1e-10)
        
        // 不同角度模式应该不同缓存
        calculator.setAngleMode(.radians)
        let result3 = try calculator.calculateWithCache(function: "sin", value: 30)
        #expect(result3 != 0.5) // 弧度制的 sin(30) 不是 0.5
    }
    
    @Test func testCacheInvalidFunction() throws {
        let calculator = ScientificCalculator()
        
        // 无效函数名应该抛出错误
        #expect(throws: ScientificCalculator.ScientificError.invalidInput) {
            _ = try calculator.calculateWithCache(function: "invalid", value: 10)
        }
    }
    
    @Test func testClearCache() throws {
        let calculator = ScientificCalculator()
        
        // 先缓存一些结果
        _ = try calculator.calculateWithCache(function: "sin", value: 30)
        _ = try calculator.calculateWithCache(function: "cos", value: 60)
        
        // 清除缓存
        calculator.clearCache()
        
        // 缓存应该被清空
        // 注意：我们无法直接访问缓存，但可以通过性能间接测试
    }
    
    // MARK: - 批量计算测试
    
    @Test func testBatchTrigonometry() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        let angles = [0.0, 30.0, 45.0, 60.0, 90.0]
        let results = try calculator.batchTrigonometry(angles)
        
        #expect(results.sines.count == angles.count)
        #expect(results.cosines.count == angles.count)
        #expect(results.tangents.count == angles.count)
        
        // 检查一些已知值
        #expect(results.sines[0] == 0, accuracy: 1e-10)      // sin(0°)
        #expect(results.sines[1] == 0.5, accuracy: 1e-10)    // sin(30°)
        #expect(results.cosines[0] == 1, accuracy: 1e-10)    // cos(0°)
        #expect(results.cosines[4] == 0, accuracy: 1e-10)    // cos(90°)
    }
    
    @Test func testBatchLogarithms() throws {
        let calculator = ScientificCalculator()
        
        let values = [1.0, 10.0, 100.0, 1000.0]
        let results = try calculator.batchLogarithms(values)
        
        #expect(results.naturalLogs.count == values.count)
        #expect(results.commonLogs.count == values.count)
        
        // 检查一些已知值
        #expect(results.commonLogs[0] == 0, accuracy: 1e-10)     // log10(1)
        #expect(results.commonLogs[1] == 1, accuracy: 1e-10)     // log10(10)
        #expect(results.commonLogs[2] == 2, accuracy: 1e-10)     // log10(100)
        #expect(results.naturalLogs[0] == 0, accuracy: 1e-10)    // ln(1)
    }
    
    @Test func testBatchLogarithmsDomainError() throws {
        let calculator = ScientificCalculator()
        
        // 包含非正数的数组应该抛出错误
        let invalidValues = [1.0, 0.0, -1.0]
        
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.batchLogarithms(invalidValues)
        }
    }
    
    // MARK: - 性能测试
    
    @Test func testPerformanceBenchmark() {
        let calculator = ScientificCalculator()
        
        let time = calculator.performanceBenchmark(iterations: 1000)
        
        #expect(time < 0.5, "1000次科学计算应在0.5秒内完成，实际时间: \(time)秒")
        
        print("科学计算性能测试结果: \(time)秒 (1000次迭代)")
    }
    
    // MARK: - 边界条件测试
    
    @Test func testExtremeValues() throws {
        let calculator = ScientificCalculator()
        
        // 测试极大值
        let largeValue = 1e100
        let sinLarge = try calculator.sin(largeValue)
        #expect(sinLarge.isFinite, "极大值的sin应该有限")
        
        // 测试极小值
        let smallValue = 1e-100
        let sinSmall = try calculator.sin(smallValue)
        #expect(sinSmall.isFinite, "极小值的sin应该有限")
        #expect(abs(sinSmall) < 1e-99, "sin(极小值) ≈ 极小值")
    }
    
    @Test func testSpecialAngles() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // 测试特殊角度
        let specialAngles = [0.0, 30.0, 45.0, 60.0, 90.0, 180.0, 270.0, 360.0]
        
        for angle in specialAngles {
            let sinValue = try calculator.sin(angle)
            let cosValue = try calculator.cos(angle)
            
            // 检查 sin² + cos² = 1
            let sumOfSquares = sinValue * sinValue + cosValue * cosValue
            #expect(abs(sumOfSquares - 1.0) < 1e-10,
                   "角度 \(angle)°: sin² + cos² = \(sumOfSquares)，应该接近1")
        }
    }
    
    // MARK: - 错误处理测试
    
    @Test func testErrorTypes() {
        let calculator = ScientificCalculator()
        
        // 测试各种错误类型
        do {
            _ = try calculator.log10(-1)
            #expect(Bool(false), "应该抛出定义域错误")
        } catch ScientificCalculator.ScientificError.domainError {
            // 预期错误
        } catch {
            #expect(Bool(false), "应该抛出ScientificError.domainError")
        }
        
        do {
            _ = try calculator.calculateWithCache(function: "invalid", value: 1)
            #expect(Bool(false), "应该抛出无效输入错误")
        } catch ScientificCalculator.ScientificError.invalidInput {
            // 预期错误
        } catch {
            #expect(Bool(false), "应该抛出ScientificError.invalidInput")
        }
    }
    
    // MARK: - 角度转换测试
    
    @Test func testAngleConversion() throws {
        let calculator = ScientificCalculator()
        
        // 测试角度制到弧度制的转换
        calculator.setAngleMode(.degrees)
        let sin30deg = try calculator.sin(30)
        #expect(sin30deg == 0.5, accuracy: 1e-10)
        
        // 切换到弧度制
        calculator.setAngleMode(.radians)
        let sin30rad = try calculator.sin(30) // 30弧度
        #expect(sin30rad != 0.5) // 应该不同
        
        // 切换回角度制
        calculator.setAngleMode(.degrees)
        let sin30degAgain = try calculator.sin(30)
        #expect(sin30degAgain == 0.5, accuracy: 1e-10)
    }
    
    @Test func testGradiansMode() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.gradians)
        
        // 100百分度 = 90度
        let sin100grad = try calculator.sin(100)
        #expect(sin100grad == 1, accuracy: 1e-10)
        
        // 200百分度 = 180度
        let sin200grad = try calculator.sin(200)
        #expect(abs(sin200grad) < 1e-10)
    }
}