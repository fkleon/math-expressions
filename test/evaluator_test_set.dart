part of 'math_expressions_test.dart';

class RealEvaluatorTests extends TestSet {
  @override
  String get name => 'Real evaluation';

  @override
  String get tags => 'evaluator';

  @override
  Map<String, Function> get testFunctions => {};

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

        // Operators: special cases
        'Power': evaluatePower,

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
        'Custom Function': evaluateCustomFunction,
        //'Composite Function': evaluateCompositeFunction,

        // Complex expressions
        'Expression': evaluateExpression,
      };

  final evaluator = RealEvaluator();

  final zero = Number(0);
  final one = Number(1);
  final two = Number(2);
  final infinity = Number(double.infinity);
  final negativeInfinity = Number(double.negativeInfinity);
  final pi = Number(math.pi);
  final e = Number(math.e);

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
      zero: 0.0,
      one: 1.0,
      Number(0.5): 0.5,
      // max precision 15 digits
      Number(999999999999999): 999999999999999
    };
    parameterized(cases);
  }

  void evaluateVector() {
    var cases = {
      Vector([Number(1.0), Number(1.0)]): 1.0,
      Vector([Number(1.0), Number(2.0)]): throwsA(isStateError),
    };
    parameterized(cases);
  }

  void evaluateInterval() {
    var cases = {
      IntervalLiteral(Number(1.0), Number(1.0)): 1.0,
      IntervalLiteral(Number(1.0), Number(2.0)): throwsA(isStateError),
    };
    parameterized(cases);
  }

  void evaluateVariable() {
    var cases = <Expression, num>{
      Variable('x'): 12,
      Variable('y'): 24,
      Variable('∞'): double.infinity,
    };

    var evaluator = RealEvaluator(ContextModel()
      ..bindVariableName('x', Number(12))
      ..bindVariableName('y', two * Variable('x'))
      ..bindVariableName('∞', Number(double.infinity)));

    parameterized(cases, evaluator: evaluator);
  }

  void evaluateBoundVariable() {
    var cases = <Expression, num>{BoundVariable(Number(9)): 9.0};
    parameterized(cases);
  }

  void evaluateUnaryOperator() {
    var cases = {
      UnaryPlus(Number(1.2)): 1.2,
      UnaryMinus(Number(1.2)): -1.2,
      UnaryMinus(UnaryMinus(Number(1.2))): 1.2,
    };
    parameterized(cases);
  }

  void evaluateBinaryOperator() {
    var num1 = two;
    var num2 = Number(5.0);

    var cases = {
      num1 + num2: 7.0,
      num1 - num2: -3.0,
      num1 * num2: 10.0,
      num1 / num2: 0.40,
      num1 % num2: 2.0,
      num1 ^ num2: 32.0,
    };
    parameterized(cases);
  }

  void evaluatePower() {
    // See https://github.com/fkleon/math-expressions/pull/66#issue-1175180681
    final x = Variable('x');
    final three = Number(3);

    var cases = {
      x ^ (two / three): closeTo(1, EPS),
      (x ^ two) ^ (one / three): closeTo(1, EPS),
      x ^ (-(two / three)): closeTo(1, EPS),
      one / (x ^ (two / three)): closeTo(1, EPS),
    };

    var ctx = ContextModel()..bindVariable(x, -Number(1));
    var eval = RealEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  void evaluateExponential() {
    var cases = {
      // e(0) -> 1
      Exponential(zero): 1.0,
      // e(-1) -> 1/e
      Exponential(-one): 1.0 / math.e,
      // e(1) -> e
      Exponential(one): math.e,
      // e(∞) -> ∞
      Exponential(infinity): double.infinity,
      // e(-∞) -> 0.0
      Exponential(negativeInfinity): 0.0,
    };
    parameterized(cases);
  }

  void evaluateLog() {
    Number base = Number(2.0);

    var cases = {
      // Log_2(0) -> -∞
      Log(base, zero): double.negativeInfinity,
      // Log_2(-1) -> NaN
      Log(base, -one): isNaN,
      // Log_2(1) -> 0.0
      Log(base, one): 0.0,
      // Log_2(∞) -> ∞
      Log(base, infinity): double.infinity,
      // Log_2(-∞) -> NaN
      Log(base, negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateLn() {
    var cases = {
      // Ln(0) -> -∞
      Ln(zero): double.negativeInfinity,
      // Ln(-0) -> -∞
      Ln(-zero): double.negativeInfinity,
      // Ln(-1) -> NaN
      Ln(-one): isNaN,
      // Ln(1) -> 0.0
      Ln(one): 0.0,
      // Ln(e) -> 1.0
      Ln(e): 1.0,
      // Ln(∞) -> 0.0
      Ln(infinity): double.infinity,
      // Ln(-∞) -> NaN
      Ln(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateRoot() {
    var grade = Number(5);
    var cases = {
      // root_5(0) = 0
      Root(grade, zero): 0.0,
      // root_5(-1) = NaN
      Root(grade, -one): isNaN,
      // root_5(1) = 1
      Root(grade, one): 1,
      // root_5(2) = 1.14869
      Root(grade, two): closeTo(1.14869, EPS),
      // root_5(∞) -> ∞
      Root(grade, infinity): double.infinity,
      /*
     *  root_5(-∞) -> ∞
     *  as of IEEE Standard 754-2008 for power function.
     *
     *  TODO  This is inconsistent with Sqrt(-∞),
     *        which is Root(2, -∞).
     */
      Root(grade, negativeInfinity): double.infinity,
    };
    parameterized(cases);
  }

  void evaluateSqrt() {
    var cases = {
      // sqrt(0) = 0
      Sqrt(zero): 0.0,
      // sqrt(-1) = NaN
      Sqrt(-one): isNaN,
      // sqrt(1) = 1
      Sqrt(one): 1,
      // sqrt(2) = SQRT2
      Sqrt(two): math.sqrt2,
      // sqrt(∞) -> ∞
      Sqrt(infinity): double.infinity,
      // sqrt(-∞) ->  NaN
      Sqrt(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateSin() {
    var cases = {
      // sin(0) -> 0.0
      Sin(zero): 0.0,
      // sin(-1) -> -0.841
      Sin(-one): closeTo(-0.84147, EPS),
      // sin(1) -> 0.841
      Sin(one): closeTo(0.84147, EPS),
      // sin(PI) -> 0
      Sin(pi): 0,
      // sin(-PI) -> 0
      Sin(-pi): 0,
      // sin(∞) -> [-1,1] / NaN
      Sin(infinity): isNaN,
      // sin(-∞) -> [-1,1] / NaN
      Sin(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateCos() {
    var cases = {
      // cos(0) -> 1.0
      Cos(zero): 1.0,
      // cos(-1) -> 0.540
      Cos(-one): closeTo(0.54030, EPS),
      // cos(1) -> 0.540
      Cos(one): closeTo(0.54030, EPS),
      // cos(PI) -> -1
      Cos(pi): -1,
      // cos(-PI) -> -1
      Cos(-pi): -1,
      // cos(PI/2) -> 0
      Cos(pi / two): 0,
      // cos(∞) -> [-1,1] / NaN
      Cos(infinity): isNaN,
      // cos(-∞) -> [-1,1] / NaN
      Cos(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateTan() {
    var cases = {
      // tan(0) -> 0.0
      Tan(zero): 0.0,
      // tan(-1) -> -1.55740
      Tan(-one): closeTo(-1.55740, EPS),
      // tan(1) -> 1.55740
      Tan(one): closeTo(1.55740, EPS),
      // tan(PI) -> 0
      Tan(pi): closeTo(0, EPS),
      // tan(-PI) -> 0
      Tan(-pi): closeTo(0, EPS),
      // tan(∞) -> <∞ / NaN
      Tan(infinity): isNaN,
      // tan(-∞) -> <∞ / NaN
      Tan(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateAsin() {
    var cases = {
      // arcsin(0) = 0
      Asin(zero): 0.0,
      // arcsin(-1) = -π/2
      Asin(-one): closeTo(-math.pi / 2, EPS),
      // arcsin(1) = π/2
      Asin(one): closeTo(math.pi / 2, EPS),
      // arcsin(2) = NaN
      Asin(two): isNaN,
      // arcsin(-2) = NaN
      Asin(-two): isNaN,
      // arcsin(∞) = -∞
      Asin(infinity): isNaN,
      // arcsin(-∞) = ∞
      Asin(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateAcos() {
    var cases = {
      // arccos(0) = π/2
      Acos(zero): closeTo(math.pi / 2, EPS),
      // arccos(-1) = π
      Acos(-one): math.pi,
      // arccos(1) = 0
      Acos(one): 0.0,
      // arccos(2) = NaN
      Acos(two): isNaN,
      // arccos(-2) = NaN
      Acos(-two): isNaN,
      // arccos(∞) = -∞
      Acos(infinity): isNaN,
      // arccos(-∞) = ∞
      Acos(negativeInfinity): isNaN,
    };
    parameterized(cases);
  }

  void evaluateAtan() {
    var cases = {
      // arctan(0) = 0
      Atan(zero): 0.0,
      // arctan(-1) = -π/4
      Atan(-one): closeTo(-math.pi / 4, EPS),
      // arctan(1) = π/4
      Atan(one): closeTo(math.pi / 4, EPS),
      // arctan(∞) = π/2
      Atan(infinity): closeTo(math.pi / 2, EPS),
      // arctan(-∞) = -π/2
      Atan(negativeInfinity): closeTo(-math.pi / 2, EPS),
    };
    parameterized(cases);
  }

  void evaluateAbs() {
    var cases = {
      // abs(0) = 0
      Abs(zero): 0.0,
      // abs(-1) = 1
      Abs(-one): 1.0,
      // abs(1) = 1
      Abs(one): 1.0,
      // abs(2) = 2
      Abs(two): 2.0,
      // abs(∞) -> ∞
      Abs(infinity): double.infinity,
      // abs(-∞) -> ∞
      Abs(negativeInfinity): double.infinity,
    };
    parameterized(cases);
  }

  void evaluateCeil() {
    var cases = {
      // ceil(0) = 0
      Ceil(zero): 0.0,
      // ceil(-1) = -1
      Ceil(-one): -1.0,
      // ceil(1) = 1
      Ceil(one): 1.0,
      // ceil(1.5) = 2.0
      Ceil(Number(1.5)): 2.0,
      // ceil(∞) = unsupported
      Ceil(infinity): throwsA(isUnsupportedError),
      // ceil(-∞) = unsupported
      Ceil(negativeInfinity): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateFloor() {
    var cases = {
      // floor(0) = 0
      Floor(zero): 0.0,
      // floor(-1) = -1
      Floor(-one): -1.0,
      // floor(1) = 1
      Floor(one): 1.0,
      // floor(1.5) = 1.0
      Floor(Number(1.5)): 1.0,
      // floor(∞) = unsupported
      Ceil(infinity): throwsA(isUnsupportedError),
      // floor(-∞) = unsupported
      Ceil(negativeInfinity): throwsA(isUnsupportedError),
    };
    parameterized(cases);
  }

  void evaluateSgn() {
    var cases = {
      // sgn(0) = 0
      Sgn(zero): 0.0,
      // sgn(-1) = -1
      Sgn(-one): -1.0,
      // sgn(1) = 1
      Sgn(one): equals(1.0),
      // sgn(2) = 1
      Sgn(two): 1.0,
      // sgn(∞) -> 1
      Sgn(infinity): 1.0,
      // sgn(-∞) -> -1
      Sgn(negativeInfinity): -1.0,
    };
    parameterized(cases);
  }

  void evaluateFactorial() {
    var cases = {
      // fac(0) = 1
      Factorial(zero): 1,
      // fac(-1) = unsupported
      Factorial(-one): throwsA(isArgumentError),
      // fac(1) = 1
      Factorial(one): 1,
      // fac(1.5) = fac(2) = 2
      Factorial(Number(1.5)): 2,
      // fac(∞) = unsupported
      Factorial(infinity): throwsA(isArgumentError),
      // fac(-∞) = unsupported
      Factorial(negativeInfinity): throwsA(isArgumentError),
    };
    parameterized(cases);
  }

  void evaluateAlgorithmicFunction() {
    var x = Variable('x');
    var cases = {
      AlgorithmicFunction('my_min', [Number(1), -Number(1), x],
          (args) => args.reduce(math.min)): -2.0,
      AlgorithmicFunction('am_pm', [], (_) => DateTime.now().hour < 12 ? 0 : 1):
          isIn([1, 0]),
    };

    var ctx = ContextModel()..bindVariable(x, -Number(2));
    var eval = RealEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  /// Tests REAL evaluation of custom functions: `R^n -> R`
  void evaluateCustomFunction() {
    var (x, y, z) = (Variable('x'), Variable('y'), Variable('z'));
    var cases = {
      // Custom SQRT (R -> R)
      CustomFunction('sqrt', [x], Sqrt(x)): 2,
      // Custom ADD (R^2 -> R)
      CustomFunction('add', [x, y], x + y): 5,
      // Custom Vector LENGTH (R^3 -> R)
      CustomFunction(
              'length', [x, y, z], Sqrt((x ^ two) + (y ^ two) + (z ^ two))):
          closeTo(5.099019, EPS),
    };

    var ctx = ContextModel()
      ..bindVariable(x, Number(4))
      ..bindVariable(y, Number(1))
      ..bindVariable(z, Number(3));
    var eval = RealEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  void evaluateCompositeFunction() {
    var (x, y, z) = (Variable('x'), Variable('y'), Variable('z'));

    // Custom FUNKYSPLAT (R -> R^3)
    var three = Number(3);
    var f =
        CustomFunction('funkysplat', [x], Vector([x - three, x, x + three]));
    var v3 = Vector3(0.0, 3.0, 6.0);

    // Custom Vector LENGTH (R^3 -> R)
    var g = CustomFunction(
        'length', [x, y, z], Sqrt((x ^ two) + (y ^ two) + (z ^ two)));

    /*
     * Simple Composite of two functions: R -> R^3 -> R
     */
    var comp = (f & g) as CompositeFunction;

    /*
     * Extended Composite of three functions: R -> R^3 -> R -> R^3
     */
    var comp2 = (comp & f) as CompositeFunction; // = f & g & f

    var cases = {
      // Should evaluate to a Vector3[0.0,3.0,6.0]
      f: v3,
      // Should evaluate to the length of v3
      comp: closeTo(v3.length, 0.0001),
      // Should evaluate to a Vector3[v3.len-3,v3.len,v3.len+3]
      // Note: Need to use EvaluationType.VECTOR here.
      comp2: throwsA(isUnsupportedError),
      /*
      comp2:
      expect(v3_2.x, closeTo(v3.length - 3.0, 0.0001));
      expect(v3_2.y, closeTo(v3.length, 0.0001));
      expect(v3_2.z, closeTo(v3.length + 3.0, 0.0001));
      */
    };

    var ctx = ContextModel()..bindVariable(x, three);
    // TODO: Need vector eval
    var eval = RealEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }

  void evaluateExpression() {
    var cases = {
      two * two + UnaryMinus(Variable('x')) * Root(Number(3), Number(125)):
          closeTo(-21.0, EPS),
      UnaryMinus(Variable('x')) *
          AlgorithmicFunction(
              'am', [], (_) => DateTime.now().hour < 12 ? 1 : 0): isIn([0, -5]),
    };

    var ctx = ContextModel()..bindVariableName('x', Number(5));
    var eval = RealEvaluator(ctx);

    parameterized(cases, evaluator: eval);
  }
}
