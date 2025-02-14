part of 'math_expressions_test.dart';

class IntervalEvaluatorTests extends TestSet {
  @override
  String get name => 'Interval evaluation';

  @override
  String get tags => 'evaluator';

  @override
  Map<String, Function> get testGroups => {
        // Literals
        'Number': evaluateNumber,
        'Vector': evaluateVector,
        'Interval': evaluateInterval,
        'Variable': evaluateVariable,
        'BoundVariable': evaluateBoundVariable,

        // Operators: generic cases
        'UnaryOperator': evaluateUnaryOperator,
        'BinaryOperator': evaluateBinaryOperator,

        // Default functions
        'Exponential': evaluateExponential,
      };

  final evaluator = IntervalEvaluator();

  final zero = Number(0);
  final one = Number(1);
  final two = Number(2);

  void parameterized(Map<Expression, dynamic> cases,
      {ExpressionEvaluator? evaluator}) {
    evaluator ??= this.evaluator;
    cases.forEach((key, value) {
      if (value is Throws) {
        test('$key -> $value',
            () => expect(() => evaluator!.evaluate(key), value));
      } else {
        test('$key -> $value', () => expect(evaluator!.evaluate(key), value));
      }
    });
  }

  void evaluateNumber() {
    var cases = {
      zero: Interval(0.0, 0.0),
      one: Interval(1.0, 1.0),
      Number(0.5): Interval(0.5, 0.5),
      // max precision 15 digits
      Number(999999999999999): Interval(999999999999999, 999999999999999)
    };
    parameterized(cases);
  }

  void evaluateVector() {
    var cases = {
      Vector([Number(1.0), Number(2.0)]): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateInterval() {
    var cases = {IntervalLiteral(Number(1.0), Number(2.0)): Interval(1.0, 2.0)};
    parameterized(cases);
  }

  void evaluateVariable() {
    var cases = <Expression, Interval>{
      Variable('x'): Interval(12, 12),
      Variable('y'): Interval(24, 24),
      Variable('∞'): Interval(double.infinity, double.infinity),
    };

    var evaluator = IntervalEvaluator(ContextModel()
      ..bindVariableName('x', Number(12))
      ..bindVariableName('y', two * Variable('x'))
      ..bindVariableName('∞', Number(double.infinity)));

    parameterized(cases, evaluator: evaluator);
  }

  void evaluateBoundVariable() {
    var cases = <Expression, Interval>{
      BoundVariable(IntervalLiteral(Number(9), Number(9))): Interval(9.0, 9.0)
    };
    parameterized(cases);
  }

  void evaluateUnaryOperator() {
    final num1 = 2.25;
    final num2 = 5.0;
    var interval = IntervalLiteral(Number(num1), Number(num2));

    var cases = {
      UnaryPlus(interval): Interval(num1, num2),
      UnaryMinus(interval): -Interval(num1, num2),
      UnaryMinus(UnaryMinus(interval)): Interval(num1, num2),
    };
    parameterized(cases);
  }

  void evaluateBinaryOperator() {
    final num1 = 2.25;
    final num2 = 5.0;
    final num3 = 199.9999999;
    var int1 = Interval(num1, num2), int2 = Interval(num2, num3);

    var n1 = Number(num1), n2 = Number(num2), n3 = Number(num3);
    var i1 = IntervalLiteral(n1, n2), i2 = IntervalLiteral(n2, n3);

    var cases = {
      i1 + i2: int1 + int2,
      i1 - i2: int1 - int2,
      i1 * i2: int1 * int2,
      i1 / i2: int1 / int2,
      i1 % i2: throwsA(isUnimplementedError),
      i1 ^ i2: Interval(57.6650390625, 3125.0),
    };
    parameterized(cases);
  }

  void evaluateExponential() {
    var cases = {
      // e(0) -> 1
      Exponential(IntervalLiteral(zero, zero)): Interval(1.0, 1.0),
    };
    parameterized(cases);
  }
}
