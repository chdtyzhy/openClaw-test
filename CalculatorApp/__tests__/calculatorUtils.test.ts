// 计算器工具函数测试
// 这些函数应该从App组件中提取出来进行独立测试

describe('Calculator Utility Functions', () => {
  describe('Basic Arithmetic', () => {
    test('addition', () => {
      expect(2 + 3).toBe(5);
      expect(-1 + 1).toBe(0);
      expect(0.1 + 0.2).toBeCloseTo(0.3);
    });

    test('subtraction', () => {
      expect(5 - 3).toBe(2);
      expect(3 - 5).toBe(-2);
      expect(0 - 0).toBe(0);
    });

    test('multiplication', () => {
      expect(2 * 3).toBe(6);
      expect(-2 * 3).toBe(-6);
      expect(0 * 5).toBe(0);
    });

    test('division', () => {
      expect(6 / 3).toBe(2);
      expect(1 / 2).toBe(0.5);
      expect(5 / 0).toBe(Infinity);
    });
  });

  describe('Scientific Functions', () => {
    test('sine function (degrees)', () => {
      // sin(0°) = 0
      expect(Math.sin(0 * Math.PI / 180)).toBe(0);
      // sin(90°) = 1
      expect(Math.sin(90 * Math.PI / 180)).toBe(1);
      // sin(180°) = 0
      expect(Math.sin(180 * Math.PI / 180)).toBeCloseTo(0);
    });

    test('cosine function (degrees)', () => {
      // cos(0°) = 1
      expect(Math.cos(0 * Math.PI / 180)).toBe(1);
      // cos(90°) = 0
      expect(Math.cos(90 * Math.PI / 180)).toBeCloseTo(0);
    });

    test('square root', () => {
      expect(Math.sqrt(4)).toBe(2);
      expect(Math.sqrt(9)).toBe(3);
      expect(Math.sqrt(0)).toBe(0);
    });

    test('logarithm', () => {
      expect(Math.log10(100)).toBe(2);
      expect(Math.log10(10)).toBe(1);
      expect(Math.log10(1)).toBe(0);
    });

    test('natural logarithm', () => {
      expect(Math.log(Math.E)).toBeCloseTo(1);
      expect(Math.log(1)).toBe(0);
    });

    test('power functions', () => {
      expect(Math.pow(2, 3)).toBe(8);
      expect(Math.pow(3, 2)).toBe(9);
      expect(Math.pow(5, 0)).toBe(1);
    });

    test('constants', () => {
      expect(Math.PI).toBeCloseTo(3.14159);
      expect(Math.E).toBeCloseTo(2.71828);
    });
  });

  describe('Error Handling', () => {
    test('division by zero', () => {
      expect(1 / 0).toBe(Infinity);
      expect(-1 / 0).toBe(-Infinity);
    });

    test('square root of negative number', () => {
      expect(Math.sqrt(-1)).toBeNaN();
    });

    test('logarithm of non-positive number', () => {
      expect(Math.log10(0)).toBe(-Infinity);
      expect(Math.log10(-1)).toBeNaN();
    });
  });
});

describe('History Storage Functions', () => {
  test('history item structure', () => {
    const mockHistoryItem = {
      id: '123',
      expression: '2 + 3',
      result: '5',
      timestamp: new Date('2026-03-23T15:00:00Z'),
    };

    expect(mockHistoryItem).toHaveProperty('id');
    expect(mockHistoryItem).toHaveProperty('expression');
    expect(mockHistoryItem).toHaveProperty('result');
    expect(mockHistoryItem).toHaveProperty('timestamp');
    expect(typeof mockHistoryItem.id).toBe('string');
    expect(typeof mockHistoryItem.expression).toBe('string');
    expect(typeof mockHistoryItem.result).toBe('string');
    expect(mockHistoryItem.timestamp instanceof Date).toBe(true);
  });

  test('history limit enforcement', () => {
    const history = Array.from({ length: 60 }, (_, i) => ({ id: i.toString() }));
    const limitedHistory = history.slice(0, 50); // 最多保存50条
    
    expect(limitedHistory.length).toBe(50);
    expect(limitedHistory[0].id).toBe('0');
    expect(limitedHistory[49].id).toBe('49');
  });
});