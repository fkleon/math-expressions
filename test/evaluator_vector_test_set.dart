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

        // Operators: generic cases
        'UnaryOperator': evaluateUnaryOperator,
        'BinaryOperator': evaluateBinaryOperator,

        // Default functions
        //'Exponential': evaluateExponential,

        // TODO:
        /*
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
        'Custom Function': evaluateCustomFunction,

        // Complex expressions
        'Expression': evaluateExpression,
        */
      };

  final evaluator = VectorEvaluator();

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
    // Evaluates as scalar
    var cases = {
      zero: 0,
      one: 1,
    };
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
    var cases = {
      IntervalLiteral(one, two): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateVariable() {
    var cases = <Expression, Vector2>{
      Variable('x'): Vector2.all(1),
      Variable('y'): Vector2.all(2),
      Variable('∞'): Vector2.all(double.infinity),
    };

    var evaluator = VectorEvaluator(ContextModel()
      ..bindVariableName('x', Vector([one, one]))
      ..bindVariableName('y', two * Variable('x'))
      ..bindVariableName(
          '∞', Vector([Number(double.infinity), Number(double.infinity)])));

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
    final num3 = 199.9999999;

    var vec1 = Vector2(num1, num2),
        vec2 = Vector2(num2, num3),
        vec3 = Vector2.all(num3);

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
    };
    parameterized(cases);
  }

  void evaluateExponential() {
    var cases = {
      // e(0) -> 1
      Exponential(Vector([zero, zero])): Vector2(1.0, 1.0),
    };
    parameterized(cases);
  }
}
