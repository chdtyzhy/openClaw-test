import Testing
import ScientificEngine

@testable import ScientificEngine

struct ScientificCalculatorTests {
    
    // MARK: - 初始化测试
    
    @Test func testInitialization() {
        let calculator = ScientificCalculator()
        
        // 默认角度模式应该是角度制
        #expect(calculator.getAngleMode() == .degrees)
    }
    
    // MARK: - 角度模式测试
    
    @Test func testAngleModeSetting() {
        let calculator = ScientificCalculator()
        
        // 测试角度制
        calculator.setAngleMode(.degrees)
        #expect(calculator.getAngleMode() == .degrees)
        
        // 测试弧度制
        calculator.setAngleMode(.radians)
        #expect(calculator.getAngleMode() == .radians)
        
        // 测试百分度制
        calculator.setAngleMode(.gradians)
        #expect(calculator.getAngleMode() == .gradians)
    }
    
    // MARK: - 三角函数测试 (角度制)
    
    @Test func testSineDegrees() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // sin(0°) = 0
        let sin0 = try calculator.sin(0)
        #expect(sin0 == 0, accuracy: 1e-10)
        
        // sin(30°) = 0.5
        let sin30 = try calculator.sin(30)
        #expect(sin30 == 0.5, accuracy: 1e-10)
        
        // sin(90°) = 1
        let sin90 = try calculator.sin(90)
        #expect(sin90 == 1, accuracy: 1e-10)
        
        // sin(180°) ≈ 0
        let sin180 = try calculator.sin(180)
        #expect(abs(sin180) < 1e-10)
    }
    
    @Test func testCosineDegrees() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // cos(0°) = 1
        let cos0 = try calculator.cos(0)
        #expect(cos0 == 1, accuracy: 1e-10)
        
        // cos(60°) = 0.5
        let cos60 = try calculator.cos(60)
        #expect(cos60 == 0.5, accuracy: 1e-10)
        
        // cos(90°) ≈ 0
        let cos90 = try calculator.cos(90)
        #expect(abs(cos90) < 1e-10)
        
        // cos(180°) = -1
        let cos180 = try calculator.cos(180)
        #expect(cos180 == -1, accuracy: 1e-10)
    }
    
    @Test func testTangentDegrees() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // tan(0°) = 0
        let tan0 = try calculator.tan(0)
        #expect(tan0 == 0, accuracy: 1e-10)
        
        // tan(45°) = 1
        let tan45 = try calculator.tan(45)
        #expect(tan45 == 1, accuracy: 1e-10)
        
        // tan(30°) ≈ 0.577350269
        let tan30 = try calculator.tan(30)
        #expect(tan30 == 0.5773502691896257, accuracy: 1e-10)
    }
    
    @Test func testTangentDomainError() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // tan(90°) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.tan(90)
        }
    }
    
    // MARK: - 三角函数测试 (弧度制)
    
    @Test func testSineRadians() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.radians)
        
        // sin(0) = 0
        let sin0 = try calculator.sin(0)
        #expect(sin0 == 0, accuracy: 1e-10)
        
        // sin(π/2) = 1
        let sinPi2 = try calculator.sin(Double.pi / 2)
        #expect(sinPi2 == 1, accuracy: 1e-10)
        
        // sin(π) ≈ 0
        let sinPi = try calculator.sin(Double.pi)
        #expect(abs(sinPi) < 1e-10)
    }
    
    // MARK: - 反三角函数测试
    
    @Test func testArcSine() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // asin(0) = 0°
        let asin0 = try calculator.asin(0)
        #expect(asin0 == 0, accuracy: 1e-10)
        
        // asin(0.5) = 30°
        let asin05 = try calculator.asin(0.5)
        #expect(asin05 == 30, accuracy: 1e-10)
        
        // asin(1) = 90°
        let asin1 = try calculator.asin(1)
        #expect(asin1 == 90, accuracy: 1e-10)
    }
    
    @Test func testArcSineDomainError() throws {
        let calculator = ScientificCalculator()
        
        // asin(1.5) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.asin(1.5)
        }
        
        // asin(-1.5) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.asin(-1.5)
        }
    }
    
    @Test func testArcCosine() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // acos(1) = 0°
        let acos1 = try calculator.acos(1)
        #expect(acos1 == 0, accuracy: 1e-10)
        
        // acos(0.5) = 60°
        let acos05 = try calculator.acos(0.5)
        #expect(acos05 == 60, accuracy: 1e-10)
        
        // acos(0) = 90°
        let acos0 = try calculator.acos(0)
        #expect(acos0 == 90, accuracy: 1e-10)
        
        // acos(-1) = 180°
        let acosMinus1 = try calculator.acos(-1)
        #expect(acosMinus1 == 180, accuracy: 1e-10)
    }
    
    @Test func testArcTangent() throws {
        let calculator = ScientificCalculator()
        calculator.setAngleMode(.degrees)
        
        // atan(0) = 0°
        let atan0 = try calculator.atan(0)
        #expect(atan0 == 0, accuracy: 1e-10)
        
        // atan(1) = 45°
        let atan1 = try calculator.atan(1)
        #expect(atan1 == 45, accuracy: 1e-10)
    }
    
    // MARK: - 对数和指数函数测试
    
    @Test func testLogarithmBase10() throws {
        let calculator = ScientificCalculator()
        
        // log10(1) = 0
        let log1 = try calculator.log10(1)
        #expect(log1 == 0, accuracy: 1e-10)
        
        // log10(10) = 1
        let log10 = try calculator.log10(10)
        #expect(log10 == 1, accuracy: 1e-10)
        
        // log10(100) = 2
        let log100 = try calculator.log10(100)
        #expect(log100 == 2, accuracy: 1e-10)
        
        // log10(0.1) = -1
        let log01 = try calculator.log10(0.1)
        #expect(log01 == -1, accuracy: 1e-10)
    }
    
    @Test func testLogarithmDomainError() throws {
        let calculator = ScientificCalculator()
        
        // log10(0) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.log10(0)
        }
        
        // log10(-1) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.log10(-1)
        }
    }
    
    @Test func testNaturalLogarithm() throws {
        let calculator = ScientificCalculator()
        
        // ln(1) = 0
        let ln1 = try calculator.ln(1)
        #expect(ln1 == 0, accuracy: 1e-10)
        
        // ln(e) = 1
        let lnE = try calculator.ln(calculator.e)
        #expect(lnE == 1, accuracy: 1e-10)
    }
    
    @Test func testExponential() {
        let calculator = ScientificCalculator()
        
        // exp(0) = 1
        let exp0 = calculator.exp(0)
        #expect(exp0 == 1, accuracy: 1e-10)
        
        // exp(1) = e
        let exp1 = calculator.exp(1)
        #expect(exp1 == calculator.e, accuracy: 1e-10)
        
        // exp(2) = e²
        let exp2 = calculator.exp(2)
        #expect(exp2 == calculator.e * calculator.e, accuracy: 1e-10)
    }
    
    @Test func testExponentialBase10() {
        let calculator = ScientificCalculator()
        
        // 10^0 = 1
        let exp10_0 = calculator.exp10(0)
        #expect(exp10_0 == 1, accuracy: 1e-10)
        
        // 10^1 = 10
        let exp10_1 = calculator.exp10(1)
        #expect(exp10_1 == 10, accuracy: 1e-10)
        
        // 10^2 = 100
        let exp10_2 = calculator.exp10(2)
        #expect(exp10_2 == 100, accuracy: 1e-10)
        
        // 10^-1 = 0.1
        let exp10_minus1 = calculator.exp10(-1)
        #expect(exp10_minus1 == 0.1, accuracy: 1e-10)
    }
    
    // MARK: - 幂和根函数测试
    
    @Test func testSquare() {
        let calculator = ScientificCalculator()
        
        // 2² = 4
        let square2 = calculator.square(2)
        #expect(square2 == 4)
        
        // (-3)² = 9
        let squareMinus3 = calculator.square(-3)
        #expect(squareMinus3 == 9)
        
        // 0² = 0
        let square0 = calculator.square(0)
        #expect(square0 == 0)
    }
    
    @Test func testCube() {
        let calculator = ScientificCalculator()
        
        // 2³ = 8
        let cube2 = calculator.cube(2)
        #expect(cube2 == 8)
        
        // (-2)³ = -8
        let cubeMinus2 = calculator.cube(-2)
        #expect(cubeMinus2 == -8)
    }
    
    @Test func testPower() throws {
        let calculator = ScientificCalculator()
        
        // 2^3 = 8
        let pow2_3 = try calculator.power(base: 2, exponent: 3)
        #expect(pow2_3 == 8)
        
        // 4^0.5 = 2
        let pow4_05 = try calculator.power(base: 4, exponent: 0.5)
        #expect(pow4_05 == 2)
        
        // 10^-2 = 0.01
        let pow10_minus2 = try calculator.power(base: 10, exponent: -2)
        #expect(pow10_minus2 == 0.01)
    }
    
    @Test func testSquareRoot() throws {
        let calculator = ScientificCalculator()
        
        // √4 = 2
        let sqrt4 = try calculator.sqrt(4)
        #expect(sqrt4 == 2)
        
        // √9 = 3
        let sqrt9 = try calculator.sqrt(9)
        #expect(sqrt9 == 3)
        
        // √0 = 0
        let sqrt0 = try calculator.sqrt(0)
        #expect(sqrt0 == 0)
        
        // √2 ≈ 1.41421356
        let sqrt2 = try calculator.sqrt(2)
        #expect(sqrt2 == 1.4142135623730951, accuracy: 1e-10)
    }
    
    @Test func testSquareRootDomainError() throws {
        let calculator = ScientificCalculator()
        
        // √(-1) 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.sqrt(-1)
        }
    }
    
    @Test func testCubeRoot() {
        let calculator = ScientificCalculator()
        
        // ³√8 = 2
        let cbrt8 = calculator.cbrt(8)
        #expect(cbrt8 == 2)
        
        // ³√(-8) = -2
        let cbrtMinus8 = calculator.cbrt(-8)
        #expect(cbrtMinus8 == -2)
        
        // ³√27 = 3
        let cbrt27 = calculator.cbrt(27)
        #expect(cbrt27 == 3)
    }
    
    @Test func testNthRoot() throws {
        let calculator = ScientificCalculator()
        
        // ⁴√16 = 2
        let root4_16 = try calculator.nthRoot(16, n: 4)
        #expect(root4_16 == 2)
        
        // ⁵√32 = 2
        let root5_32 = try calculator.nthRoot(32, n: 5)
        #expect(root5_32 == 2)
    }
    
    @Test func testNthRootDomainError() throws {
        let calculator = ScientificCalculator()
        
        // 偶次根号下负数应该抛出错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.nthRoot(-16, n: 4)
        }
    }
    
    @Test func testNthRootInvalidInput() throws {
        let calculator = ScientificCalculator()
        
        // n <= 0 应该抛出无效输入错误
        #expect(throws: ScientificCalculator.ScientificError.invalidInput) {
            _ = try calculator.nthRoot(16, n: 0)
        }
        
        #expect(throws: ScientificCalculator.ScientificError.invalidInput) {
            _ = try calculator.nthRoot(16, n: -2)
        }
    }
    
    // MARK: - 其他数学函数测试
    
    @Test func testFactorial() throws {
        let calculator = ScientificCalculator()
        
        // 0! = 1
        let fact0 = try calculator.factorial(0)
        #expect(fact0 == 1)
        
        // 1! = 1
        let fact1 = try calculator.factorial(1)
        #expect(fact1 == 1)
        
        // 5! = 120
        let fact5 = try calculator.factorial(5)
        #expect(fact5 == 120)
        
        // 10! = 3628800
        let fact10 = try calculator.factorial(10)
        #expect(fact10 == 3628800)
    }
    
    @Test func testFactorialDomainError() throws {
        let calculator = ScientificCalculator()
        
        // 负数阶乘应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.factorial(-1)
        }
    }
    
    @Test func testFactorialOverflow() throws {
        let calculator = ScientificCalculator()
        
        // 171! 应该抛出溢出错误（Double无法表示）
        #expect(throws: ScientificCalculator.ScientificError.overflow) {
            _ = try calculator.factorial(171)
        }
    }
    
    @Test func testReciprocal() throws {
        let calculator = ScientificCalculator()
        
        // 1/2 = 0.5
        let rec2 = try calculator.reciprocal(2)
        #expect(rec2 == 0.5)
        
        // 1/4 = 0.25
        let rec4 = try calculator.reciprocal(4)
        #expect(rec4 == 0.25)
        
        // 1/(-5) = -0.2
        let recMinus5 = try calculator.reciprocal(-5)
        #expect(recMinus5 == -0.2)
    }
    
    @Test func testReciprocalDomainError() throws {
        let calculator = ScientificCalculator()
        
        // 1/0 应该抛出定义域错误
        #expect(throws: ScientificCalculator.ScientificError.domainError) {
            _ = try calculator.reciprocal(0)
        }
    }
    
    @Test func testAbsoluteValue() {
        let calculator = ScientificCalculator()
        
        // |5| = 5
        let abs5 = calculator.abs(5)
        #expect(abs5 == 5)
        
        // |-5| = 5
        let absMinus5 = calculator.abs(-5)
        #expect(absMinus5 == 5)
        
        // |0| = 0
        let abs0 = calculator.abs(0)
        #expect(abs0 == 0)
    }
    
    // MARK: - 常数测试
    
    @Test func testConstants() {
        let calculator = ScientificCalculator()
        
        // π 值测试
        let pi = calculator.pi
        #expect(pi == Double.pi, accuracy: 1e-15)
        
        // e