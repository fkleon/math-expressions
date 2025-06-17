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

    // Operators
    'UnaryOperator': evaluateUnaryOperator,
    'BinaryOperator': evaluateBinaryOperator,

    // Default functions
    'Exponential': evaluateExponential,
    'Log': evaluateLog,
    'Ln': evaluateLn,
    'Root': evaluateRoot,
    'Sqrt': evaluateSqrt,
    'Sin': evaluateSin,
    'Cos': evaluateCos,
    'Tan': evaluateTan,
    'Asin': evaluateAsin,
    'Acos': evaluateAcos,
    'Atan': evaluateAtan,
    'Abs': evaluateAbs,
    'Ceil': evaluateCeil,
    'Floor': evaluateFloor,
    'Sgn': evaluateSgn,
    'Factorial': evaluateFactorial,

    // Custom functions
    'Algorithmic Function': evaluateAlgorithmicFunction,
    // 'Custom Function': evaluateCustomFunction,

    // Complex expressions
    'Expression': evaluateExpression,
  };

  final evaluator = IntervalEvaluator();

  final zero = Number(0);
  final one = Number(1);
  final two = Number(2);
  final pi = Number(math.pi);

  void parameterized(
    Map<Expression, dynamic> cases, {
    ExpressionEvaluator? evaluator,
  }) {
    evaluator ??= this.evaluator;
    cases.forEach((key, value) {
      if (value is Throws) {
        test(
          '$key -> $value',
          () => expect(() => evaluator!.evaluate(key), value),
        );
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
      Number(999999999999999): Interval(999999999999999, 999999999999999),
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

    var evaluator = IntervalEvaluator(
      ContextModel()
        ..bindVariableName('x', Number(12))
        ..bindVariableName('y', two * Variable('x'))
        ..bindVariableName('∞', Number(double.infinity)),
    );

    parameterized(cases, evaluator: evaluator);
  }

  void evaluateBoundVariable() {
    var cases = <Expression, Interval>{
      BoundVariable(IntervalLiteral(Number(9), Number(9))): Interval(9.0, 9.0),
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
      i1 ^ n2: Interval(57.6650390625, 3125.0),
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

  void evaluateLog() {
    Number base = Number(2.0);

    var cases = {
      // Log_2(0) -> -∞
      Log(base, IntervalLiteral(zero, zero)): Interval(
        double.negativeInfinity,
        double.negativeInfinity,
      ),
    };
    parameterized(cases);
  }

  void evaluateLn() {
    var cases = {
      // Ln(0) -> -∞
      Ln(IntervalLiteral(zero, zero)): Interval(
        double.negativeInfinity,
        double.negativeInfinity,
      ),
      // Ln(1) -> 0
      Ln(IntervalLiteral(one, zero)): Interval(0, double.negativeInfinity),
    };
    parameterized(cases);
  }

  void evaluateRoot() {
    var grade = Number(5);
    var cases = {
      // root_5(0) = 0
      // TODO: Check correctness
      Root(grade, IntervalLiteral(zero, zero)): Interval(0, 1.0),
    };
    parameterized(cases);
  }

  void evaluateSqrt() {
    var cases = {
      Sqrt(IntervalLiteral(zero, zero)): Interval(0, 0),
      Sqrt(IntervalLiteral(Number(4), Number(9))): Interval(2, 3),
    };
    parameterized(cases);
  }

  void evaluateSin() {
    var cases = {
      Sin(IntervalLiteral(zero, zero)): throwsA(isUnimplementedError),
    };
    parameterized(cases);
  }

  void evaluateCos() {
    var cases = {
      Cos(IntervalLiteral(zero, zero)): throwsA(isUnimplementedError),
    };
    parameterized(cases);
  }

  void evaluateTan() {
    var cases = {Tan(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError)};
    parameterized(cases);
  }

  void evaluateAsin() {
    var cases = {
      Asin(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateAcos() {
    var cases = {
      Acos(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateAtan() {
    var cases = {
      Atan(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateAbs() {
    var cases = {Abs(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError)};
    parameterized(cases);
  }

  void evaluateCeil() {
    var cases = {
      Ceil(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateFloor() {
    var cases = {
      Floor(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateSgn() {
    var cases = {Sgn(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError)};
    parameterized(cases);
  }

  void evaluateFactorial() {
    var cases = {
      Factorial(IntervalLiteral(zero, zero)): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateAlgorithmicFunction() {
    var x = Variable('x');
    var cases = {
      AlgorithmicFunction('identity', [x], (args) => args[0]): throwsA(
        isUnimplementedError,
      ),
    };

    var ctx = ContextModel()..bindVariable(x, IntervalLiteral(zero, one));
    var eval = IntervalEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  void evaluateExpression() {
    var x = Variable('x');
    var cases = {
      IntervalLiteral(zero + Cos(pi), one / two): Interval(-1, 0.5),
      IntervalLiteral(-x, x / -x): Interval(-1, -1),
    };

    var ctx = ContextModel()..bindVariable(x, one);
    var eval = IntervalEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }
}
