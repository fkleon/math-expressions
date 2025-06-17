part of 'math_expressions_test.dart';

class VectorEvaluatorTests extends TestSet {
  @override
  String get name => 'Vector evaluation';

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
    //'Custom Function': evaluateCustomFunction,

    // Complex expressions
    'Expression': evaluateExpression,
  };

  final evaluator = VectorEvaluator();

  final zero = Number(0);
  final one = Number(1);
  final two = Number(2);

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
    // Evaluates as scalar
    var cases = {zero: 0, one: 1};
    parameterized(cases);
  }

  void evaluateVector() {
    var cases = {
      Vector([]): throwsA(TypeMatcher<AssertionError>()), // no result
      Vector([one]): 1,
      Vector([one, two]): Vector2(1, 2),
      Vector([zero, one, two]): Vector3(0, 1, 2),
      Vector([zero, one, two, zero]): Vector4(0, 1, 2, 0),
      Vector([zero, one, two, zero, one]): throwsA(isUnsupportedError),
      Vector([one * two]): 2,
      Vector([one * two, two]): Vector2(2, 2),
    };
    parameterized(cases);
  }

  void evaluateInterval() {
    var cases = {IntervalLiteral(one, two): throwsA(isUnsupportedError)};
    parameterized(cases);
  }

  void evaluateVariable() {
    var cases = <Expression, Vector2>{
      Variable('x'): Vector2.all(1),
      Variable('y'): Vector2.all(2),
      Variable('∞'): Vector2.all(double.infinity),
    };

    var evaluator = VectorEvaluator(
      ContextModel()
        ..bindVariableName('x', Vector([one, one]))
        ..bindVariableName('y', Variable('x') * two)
        ..bindVariableName(
          '∞',
          Vector([Number(double.infinity), Number(double.infinity)]),
        ),
    );

    parameterized(cases, evaluator: evaluator);
  }

  void evaluateBoundVariable() {
    var cases = <Expression, Vector2>{
      BoundVariable(Vector([Number(9), Number(9)])): Vector2.all(9),
    };
    parameterized(cases);
  }

  void evaluateUnaryOperator() {
    final num1 = 2.25;
    var vector = Vector2.all(num1);

    var n1 = Number(num1);
    var v = Vector([n1, n1]);

    var cases = {
      UnaryPlus(v): vector,
      UnaryMinus(v): -vector,
      UnaryMinus(UnaryMinus(v)): vector,
    };
    parameterized(cases);
  }

  void evaluateBinaryOperator() {
    final num1 = 2.25;
    final num2 = 5.0;
    final num3 = 200.0;

    var vec1 = Vector2(num1, num2), vec2 = Vector2(num2, num3);

    var n1 = Number(num1), n2 = Number(num2), n3 = Number(num3);
    var v1 = Vector([n1, n2]), v2 = Vector([n2, n3]);

    var cases = {
      // vector and vector
      v1 + v2: vec1 + vec2,
      v1 - v2: vec1 - vec2,
      v1 * v2: vec1.clone()..multiply(vec2), // modifies vec1 inplace
      v1 / v2: vec1.clone()..divide(vec2), // modifies vec1 inplace
      v1 % v2: throwsA(isUnimplementedError),
      v1 ^ n2: throwsA(isUnimplementedError),
      // vector and scalar
      v1 + n2: throwsA(isUnsupportedError),
      v1 - n2: throwsA(isUnsupportedError),
      v1 * n2: vec1 * num2,
      v1 / n2: vec1 / num2,
      v1 % n2: throwsA(isUnimplementedError),
      v1 ^ n2: throwsA(isUnimplementedError),
      // vector and scalar: scalar must be on right-hand side of expression
      n2 * v1: throwsA(isArgumentError),
      n2 / v1: throwsA(isArgumentError),
    };
    parameterized(cases);
  }

  void evaluateExponential() {
    var cases = {
      Exponential(Vector([zero, zero])): throwsA(isUnimplementedError),
    };
    parameterized(cases);
  }

  void evaluateLog() {
    Number base = Number(2.0);

    var cases = {Log(base, Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateLn() {
    var cases = {Ln(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateRoot() {
    var grade = Number(5);
    var cases = {Root(grade, Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateSqrt() {
    var cases = {Sqrt(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateSin() {
    var cases = {Sin(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateCos() {
    var cases = {Cos(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateTan() {
    var cases = {Tan(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateAsin() {
    var cases = {Asin(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateAcos() {
    var cases = {Acos(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateAtan() {
    var cases = {Atan(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateAbs() {
    var cases = {Abs(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateCeil() {
    var cases = {Ceil(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateFloor() {
    var cases = {Floor(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateSgn() {
    var cases = {Sgn(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateFactorial() {
    var cases = {Factorial(Vector([])): throwsA(isUnimplementedError)};
    parameterized(cases);
  }

  void evaluateAlgorithmicFunction() {
    var x = Variable('x');
    var cases = {
      AlgorithmicFunction('identity', [x], (args) => args[0]): throwsA(
        isUnimplementedError,
      ),
    };

    var ctx = ContextModel()..bindVariable(x, Vector([zero, one]));
    var eval = VectorEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  void evaluateExpression() {
    var x = Variable('x');
    var cases = {
      Vector([Exponential(zero), Sqrt(Number(4.0))]): Vector2(1.0, 2.0),
      Vector([Exponential(zero), two * Sqrt(one) + x]): Vector2(1.0, 3.0),
    };

    var ctx = ContextModel()..bindVariable(x, one);
    var eval = VectorEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }
}
