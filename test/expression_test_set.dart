// ignore_for_file: unused_local_variable
part of 'math_expressions_test.dart';

/// Contains methods to test the math expression implementation.
class ExpressionTests extends TestSet {
  @override
  String get name => 'Expression Tests';

  @override
  String get tags => 'expression';

  @override
  Map<String, Function> get testFunctions => {
        'Expression creation [REAL]': simpleRealCreation,
        'Expression creation [INTERVAL]': simpleIntervalCreation,
        'Expression Creation [VECTOR]': simpleVectorCreation,
        'Binary Op Convenience creation': convenienceBinaryCreation,
        'Unary Op Convenience creation': convenienceUnaryCreation,
        'Operator simplification': baseOperatorSimplification,
        'Operator differentiation': baseOperatorDifferentiation,
        'Default Function creation': defFuncCreation,
        'Default Function simplification': defFuncSimplification,
        'Default Function differentiation': defFuncDifferentiation,
        'Custom Function creation': cusFuncCreation,
        /*
        'Custom Function simplification': cusFuncSimplification,
        'Custom Function differentiation': cusFuncDifferentiation,
        */
        'Composite Function creation': compFunCreation,
        /*
        'Composite Function simplification': compFuncSimplification,
        'Composite Function differentiation': compFuncDifferentiation,
        */
        'Composite Function evaluation': compFunEval,
        'Algorithmic Function creation': algorithmicFunctionCreation,
        'Expression visitor': testVisitor,
      };

  @override
  void initTests() {
    num1 = 2.25;
    num2 = 5.0;
    num3 = 199.9999999;
    n1 = Number(num1);
    n2 = Number(num2);
    n3 = Number(num3);

    int1 = Interval(num1, num2);
    int2 = Interval(num2, num3);
    int3 = Interval(-num3, num2);

    i1 = IntervalLiteral(n1, n2);
    i2 = IntervalLiteral(n2, n3);
    i3 = IntervalLiteral(-n3, n2);

    v1 = Vector([n1, n1, n1]);
    v2 = Vector([n2, n2, n2]);
    v3 = Vector([n3, n3, n3]);
    //v4 = Vector([n4, n4, n4]);

    real = EvaluationType.REAL;
    interval = EvaluationType.INTERVAL;
    vector = EvaluationType.VECTOR;

    cm = ContextModel();
  }

  late num num1, num2, num3;
  late Interval int1, int2, int3;

  late Number n1, n2, n3, n4;
  late IntervalLiteral i1, i2, i3;
  late Vector v1, v2, v3;
  late Expression e1, e2, e3, e4, e5, e6;

  late EvaluationType real, interval, vector;
  late ContextModel cm;

  void _createBasicExpressions(EvaluationType type) {
    if (type == EvaluationType.REAL) {
      e1 = n1 * n2;
      e2 = n1 / n2;
      e3 = n1 ^ n2;
      e4 = n1 + n2;
      e5 = n1 - n2;
      e6 = -n1;
      return;
    }

    if (type == EvaluationType.INTERVAL) {
      e1 = i1 * i2;
      e2 = i1 / i2;
      e3 = i1 ^ i2;
      e4 = i1 + i2;
      e5 = i1 - i2;
      e6 = -i1;
      return;
    }

    if (type == EvaluationType.VECTOR) {
      e1 = v1 * v2;
      e2 = v1 / v2;
      e3 = v1 ^ v2;
      e4 = v1 + v2;
      e5 = v1 - v2;
      e6 = -v1;
      return;
    }
  }

  /// Tests the constructors of expressions.
  void simpleRealCreation() {
    _createBasicExpressions(real);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, n1, n2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, n1, n2), isTrue);

    expect(e3 is Power, isTrue);
    expect(_hasMember(e3, n1, n2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, n1, n2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, n1, n2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, n1), isTrue);
  }

  /// Tests the convenience constructors (binary, auto-wrapping).
  void convenienceBinaryCreation() {
    // Test Expression creation with convenience constructors.
    List<BinaryOperator> binOps = [
      Times('x', 2),
      Divide('x', 2),
      Plus('x', 2),
      Minus('x', 2),
      Power('x', 2)
    ];

    for (BinaryOperator binOp in binOps) {
      expect(binOp.first, TypeMatcher<Variable>());
      expect(binOp.second, TypeMatcher<Number>());
    }
  }

  /// Tests the convenience constructors (unary, auto-wrapping).
  void convenienceUnaryCreation() {
    List<UnaryOperator> unOps = [UnaryMinus('x'), UnaryPlus('x')];

    for (UnaryOperator unOp in unOps) {
      expect(unOp.exp, TypeMatcher<Variable>());
    }
  }

  /// Tests the interval constructors.
  void simpleIntervalCreation() {
    _createBasicExpressions(interval);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, i1, i2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, i1, i2), isTrue);

    expect(e3 is Power, isTrue);
    expect(_hasMember(e3, i1, i2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, i1, i2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, i1, i2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, i1), isTrue);
  }

  /// Tests the vector constructors.
  void simpleVectorCreation() {
    _createBasicExpressions(vector);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, v1, v2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, v1, v2), isTrue);

    expect(e3 is Power, isTrue);
    expect(_hasMember(e3, v1, v2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, v1, v2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, v1, v2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, v1), isTrue);
  }

  /// Tests simplification of basic operator expressions.
  void baseOperatorSimplification() {
    /*
     *  Plus
     */
    // a + 0 = a
    Expression exp = Plus('a', 0);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 0 + a = a
    exp = Plus(0, 'a');
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // a + -(b) = a - b
    exp = Plus('a', UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<Minus>());
    expect((exp.simplify() as Minus).first, TypeMatcher<Variable>());
    expect((exp.simplify() as Minus).second, TypeMatcher<Variable>());

    // a - +(b) = a - b
    exp = Minus('a', UnaryPlus('b'));
    expect(exp.simplify(), TypeMatcher<Minus>());
    expect((exp.simplify() as Minus).first, TypeMatcher<Variable>());
    expect((exp.simplify() as Minus).second, TypeMatcher<Variable>());

    /*
     *  Minus
     */
    // a - 0 = a
    exp = Minus('a', 0);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 0 - a = - a
    exp = Minus(0, 'a');
    expect(exp.simplify(), TypeMatcher<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, TypeMatcher<Variable>());

    // a - -(b) = a + b
    exp = Minus('a', UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<Plus>());
    expect((exp.simplify() as Plus).first, TypeMatcher<Variable>());
    expect((exp.simplify() as Plus).second, TypeMatcher<Variable>());

    // a + +(b) = a + b
    exp = Plus('a', UnaryPlus('b'));
    expect(exp.simplify(), TypeMatcher<Plus>());
    expect((exp.simplify() as Plus).first, TypeMatcher<Variable>());
    expect((exp.simplify() as Plus).second, TypeMatcher<Variable>());

    /*
     *  Times
     */
    // -a * b = - (a * b)
    exp = Times(UnaryMinus('a'), 'b');
    expect(exp.simplify(), TypeMatcher<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, TypeMatcher<Times>());
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Times).first, 'a'),
        isTrue);
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Times).second, 'b'),
        isTrue);

    // a * -b = - (a * b)
    exp = Times('a', UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, TypeMatcher<Times>());
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Times).first, 'a'),
        isTrue);
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Times).second, 'b'),
        isTrue);

    // -a * -b = a * b
    exp = Times(UnaryMinus('a'), UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<Times>());
    expect(_isVariable((exp.simplify() as Times).first, 'a'), isTrue);
    expect(_isVariable((exp.simplify() as Times).second, 'b'), isTrue);

    // a * 0 = 0
    exp = Times(UnaryMinus('a'), 0);
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // 0 * a = 0
    exp = Times(0, Variable('a'));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // a * 1 = a
    exp = Times(Variable('a'), 1);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 1 * a = a
    exp = Times(1, Variable('a'));
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    /*
     *  Divide
     */
    // -a / b = - (a / b)
    exp = Divide(UnaryMinus('a'), 'b');
    expect(exp.simplify(), TypeMatcher<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, TypeMatcher<Divide>());
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Divide).first, 'a'),
        isTrue);
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Divide).second, 'b'),
        isTrue);

    // a * -b = - (a / b)
    exp = Divide('a', UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, TypeMatcher<Divide>());
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Divide).first, 'a'),
        isTrue);
    expect(
        _isVariable(((exp.simplify() as UnaryMinus).exp as Divide).second, 'b'),
        isTrue);

    // -a / -b = a / b
    exp = Divide(UnaryMinus('a'), UnaryMinus('b'));
    expect(exp.simplify(), TypeMatcher<Divide>());
    expect(_isVariable((exp.simplify() as Divide).first, 'a'), isTrue);
    expect(_isVariable((exp.simplify() as Divide).second, 'b'), isTrue);

    // 0 / a = 0
    exp = Divide(0, Variable('a'));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // a / 1 = a
    exp = Divide(Variable('a'), 1);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    /*
     *  Power
     */
    // 0^x = 0
    exp = Power(0, 'x');
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // 1^x = 1
    exp = Power(1, 'x');
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // x^0 = 1
    exp = Power('x', 0);
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // x^1 = x
    exp = Power('x', 1);
    expect(_isVariable(exp.simplify(), 'x'), isTrue);

    /*
     *  Unary Minus
     */
    // -(-a) = a
    exp = UnaryMinus(UnaryMinus('a'));
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // -0 = 0
    exp = UnaryMinus(0);
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     *  Unary Plus
     */
    // +(+a) = a
    exp = UnaryPlus(UnaryPlus('a'));
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // +0 = 0
    exp = UnaryPlus(0);
    expect((exp.simplify() as Number).value == 0, isTrue);
  }

  /// Tests differentiation of basic operators.
  void baseOperatorDifferentiation() {
    var diff = [
      // Expression,         deriveTo, output,     outputSimplified
      [Plus(1, 'x'), 'x', '0.0+1.0', '1.0'],
      [Plus(1, 1), 'x', '0.0+0.0', '0.0'],
      [Minus(1, 'x'), 'x', '0.0-1.0', '-1.0'],
      [Minus('x', 1), 'x', '1.0-0.0', '1.0'],
      [Times('x', 1), 'x', 'x*0.0+1.0*1.0', '1.0'],
      [Divide('x', 2), 'x', '((1.0*2.0)-(x*0.0))/(2.0*2.0)', '2.0/(2.0*2.0)'],
      [
        Modulo('x', 'x'),
        'x',
        '1.0 - floor(x / abs(x)) * (sgn(x) * 1.0)',
        '1.0 - floor(x / abs(x)) * sgn(x)'
      ],
      [
        Power('x', 2),
        'x',
        'e(2.0 * ln(x)) * ((2.0 * (1.0 / x)) + (0.0 * ln(x)))',
        'x^2.0 * (2.0 * (1.0 / x))' // = (2x^2)/x = 2x
      ],
    ];

    for (List exprCase in diff) {
      Expression exp = exprCase[0];
      String deriveTo = exprCase[1];
      String expected = exprCase[2];
      String expectedSimpl = exprCase[3];
      expect(
          exp.derive(deriveTo), _equalsExpression(expected, simplify: false));
      expect(exp.derive(deriveTo), _equalsExpression(expectedSimpl));
    }
  }

  /// Tests creation of default functions.
  void defFuncCreation() {
    // Create all the default functions:
    // Log, Ln, Cos, Sin, Tan, Pow, etc.

    // Test with number literal
    Expression exp = n2;
    List<MathFunction> functions = _createDefaultFunctions(n2);

    for (MathFunction fun in functions) {
      // Numbers get boxed into BoundVariable, check for those instead of contains
      expect(fun.args, anyElement(TypeMatcher<BoundVariable>()));
    }

    // Test with variable
    exp = Variable('x');
    functions = _createDefaultFunctions(exp);

    for (MathFunction fun in functions) {
      // Variables should not get boxed, test for contains
      expect(fun.args, contains(exp));
    }
  }

  /// Helper function to create a list of all default functions.
  List<MathFunction> _createDefaultFunctions(Expression exp) => [
        Exponential(exp),
        Log(exp, exp),
        Ln(exp),
        Root(Number(5), exp),
        Root.sqrt(exp),
        Sqrt(exp),
        Sin(exp),
        Cos(exp),
        Tan(exp),
        Asin(exp),
        Acos(exp),
        Atan(exp),
        Ceil(exp),
        Floor(exp),
        Abs(exp),
        Sgn(exp),
        Factorial(exp)
      ];

  /// Tests simplification of default functions.
  void defFuncSimplification() {
    /*
     *  Exponential
     */
    // e^0 = 1
    Expression exp = Exponential(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // e^1 = e
    exp = Exponential(Number(1));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == math.e, isTrue);

    // e^(x*ln(y)) = y^x
    exp = Exponential(Variable('x') * Ln(Variable('y')));
    expect(exp.simplify(), TypeMatcher<Power>());
    expect(_isVariable((exp.simplify() as Power).first, 'y'), isTrue);
    expect(_isVariable((exp.simplify() as Power).second, 'x'), isTrue);

    /*
     *  Log
     */
    // Simplify base and argument
    //TODO

    /*
     *  Ln
     */
    // ln(1) = 0
    exp = Ln(Number(1));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     * Root
     */
    // Simplify argument
    //TODO

    /*
     * Sqrt
     */
    // sqrt(x^2) = x
    exp = Sqrt(Power('x', 2));
    expect(_isVariable(exp.simplify(), 'x'), isTrue);

    // sqrt(0) = 0
    exp = Sqrt(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // sqrt(1) = 1
    exp = Sqrt(Number(1));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    /*
     * Sin
     */
    // sin(0) = 0
    exp = Sin(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     * Cos
     */
    // cos(0) = 1
    exp = Cos(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    /*
     * Tan
     */
    // tan(0) = 0
    exp = Tan(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     * Asin
     */
    exp = Asin(Number(0));
    expect((exp.simplify() as Asin).arg, TypeMatcher<Variable>());

    /*
     * Acos
     */
    exp = Acos(Number(0));
    expect((exp.simplify() as Acos).arg, TypeMatcher<Variable>());

    /*
     * Atan
     */
    exp = Atan(Number(0));
    expect((exp.simplify() as Atan).arg, TypeMatcher<Variable>());

    /*
     * Abs
     */
    exp = Abs(Number(0));
    expect(exp.simplify(), TypeMatcher<Abs>());
    expect((exp.simplify() as Abs).arg, TypeMatcher<BoundVariable>());

    /*
     * Ceil
     */
    exp = Ceil(Floor(Variable('x')));
    expect((exp.simplify() as Floor).arg, TypeMatcher<Variable>());

    /*
     * Floor
     */
    exp = Floor(Ceil(Variable('x')));
    expect((exp.simplify() as Ceil).arg, TypeMatcher<Variable>());

    /*
     * Sgn
     */
    exp = Sgn(Number(0));
    expect(exp.simplify(), TypeMatcher<Sgn>());
    expect((exp.simplify() as Sgn).arg, TypeMatcher<BoundVariable>());

    /*
     * Factorial
     */
    exp = Factorial(Number(0));
    expect(exp.simplify(), TypeMatcher<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);
  }

  /// Tests differentiation of default functions.
  void defFuncDifferentiation() {
    Variable x = Variable('x');
    Number two = Number(2);
    var diff = [
      // Expression,  deriveTo, output, outputSimplified
      [Exponential(x), 'x', 'e(x) * 1.0', 'e(x)'],
      [Ln(x), 'x', '1.0 / x', '1.0 / x'],
      // TODO Simplify can't cancel out terms yet, so the
      //      simplified version is still a but ugly:
      [
        Log(two, x),
        'x',
        '((((1.0 / x) * ln(2.0)) - (ln(x) * (0.0 / 2.0))) / (ln(2.0) * ln(2.0)))',
        '(((1.0 / x) * ln(2.0)) / (ln(2.0) * ln(2.0)))'
      ],
      //'1.0 / (x * ln(2.0))'],

      // TODO Roots are internally handled as Powers:
      //[Sqrt(x),        'x', '0.0', '0.0'],
      //[Root(2, x),     'x', '0.0', '0.0'],

      [Sin(x), 'x', 'cos(x) * 1.0', 'cos(x)'],
      [Cos(x), 'x', '-sin(x) * 1.0', '-sin(x)'],

      // TODO Tan is internally handled as sin/cos:
      //[Tan(x),          'x', '0.0',    '0.0']

      [Asin(x), 'x', '1.0 / sqrt(1.0 - x ^ 2.0)', '1.0 / sqrt(1.0 - x ^ 2.0)'],
      [
        Acos(x),
        'x',
        '- 1.0 / sqrt(1.0 - x ^ 2.0)',
        '-(1.0 / sqrt(1.0 - x ^ 2.0))'
      ],
      [Atan(x), 'x', '1.0 / (1.0 + x^2.0)', '1.0 / (1.0 + x^2.0)'],

      [Abs(x), 'x', 'sgn(x) * 1.0', 'sgn(x)'],
      [
        Abs(two * x),
        'x',
        'sgn(2.0 * x) * (2.0 * 1.0 + 0.0 * x)',
        'sgn(2.0 * x) * 2.0'
      ]
    ];

    for (List exprCase in diff) {
      Expression exp = exprCase[0];
      String deriveTo = exprCase[1];
      String expected = exprCase[2];
      String expectedSimpl = exprCase[3];
      expect(
          exp.derive(deriveTo), _equalsExpression(expected, simplify: false));
      expect(exp.derive(deriveTo), _equalsExpression(expectedSimpl));
    }
  }

  /// Tests creation of custom functions.
  void cusFuncCreation() {
    // Create some custom functions.
    Variable x = Variable('x');
    List<Variable> vars = [x];
    CustomFunction cf = CustomFunction('sqrt', vars, Sqrt(x));

    expect(cf.domainDimension, equals(vars.length));
    expect(cf.expression, TypeMatcher<Sqrt>());

    //TODO more tests.
  }

  /// Tests simplification of custom functions.
  void cusFuncSimplification() {
    throw UnimplementedError();
  }

  /// Tests differentiation of custom functions.
  void cusFuncDifferentiation() {
    throw UnimplementedError();
  }

  /// Tests creation of composite functions.
  void compFunCreation() {
    Variable x, y, z;
    CustomFunction f, g;

    x = Variable('x');
    y = Variable('y');
    z = Variable('z');

    // Custom FUNKYSPLAT (R -> R^3)
    Expression three = Number(3);
    f = CustomFunction('funkysplat', [x], Vector([x - three, x, x + three]));

    // Custom Vector LENGTH (R^3 -> R)
    Expression two = Number(2);
    g = CustomFunction(
        'length', [x, y, z], Sqrt((x ^ two) + (y ^ two) + (z ^ two)));

    /*
     * Simple Composite of two functions: R -> R^3 -> R
     */
    CompositeFunction comp = (f & g) as CompositeFunction;

    expect(comp.domainDimension, equals(1));
    expect(comp.gDomainDimension, equals(3));
    expect(comp.f, equals(f));
    expect(comp.g, equals(g));

    /*
     * Extended Composite of three functions: R -> R^3 -> R -> R^3
     */
    CompositeFunction comp2 = (comp & f) as CompositeFunction; // = f & g & f

    expect(comp2.domainDimension, equals(1));
    expect(comp2.gDomainDimension, equals(1));
    expect(comp2.f, TypeMatcher<CompositeFunction>());
    expect(comp2.f, equals(comp));
    expect(comp2.g, equals(f));
  }

  /// Tests simplification of composite functions.
  void compFuncSimplification() {
    throw UnimplementedError();
  }

  /// Tests differentiation of composite functions.
  void compFuncDifferentiation() {
    throw UnimplementedError();
  }

  /// Tests evaluation of composite functions.
  void compFunEval() {
    // See https://github.com/fkleon/math-expressions/pull/66#issue-1175180681
    final x = Variable('x');
    final one = Number(1), two = Number(2), three = Number(2);
    final f = Power(x, Divide(two, three));
    final g = Power(Power(x, two), Divide(one, three));

    final contextModel = ContextModel()..bindVariable(x, Number(-1));

    final double result1 = f.evaluate(EvaluationType.REAL, contextModel);
    final double result2 = g.evaluate(EvaluationType.REAL, contextModel);

    expect(result1, closeTo(1, EPS));
    expect(result2, closeTo(1, EPS));

    final h = Power(x, UnaryMinus(Divide(two, three)));
    final i = Divide(one, Power(x, Divide(two, three)));

    final double result3 = h.evaluate(EvaluationType.REAL, contextModel);
    final double result4 = i.evaluate(EvaluationType.REAL, contextModel);
    expect(result3, closeTo(1, EPS));
    expect(result4, closeTo(1, EPS));
  }

  /// Tests creation of algorithmic functions.
  void algorithmicFunctionCreation() {
    handler(List<double> args) => args.reduce(math.min);

    // Generic list minimum (R^2 -> R)
    AlgorithmicFunction f = AlgorithmicFunction('my_min', [n1, -n1], handler);

    expect(f.name, equals('my_min'));
    //expect(f.args, equals([BoundVariable(n1), BoundVariable(-n1)]));
    expect(f.handler, equals(handler));
  }

  void testVisitor() {
    var exp = Exponential(UnaryMinus(Number(0) + Variable('x')));
    var visitor = VariableCollector();
    var variables = visitor.evaluate(exp);
    expect(variables, equals({'x'}));
  }

  /// Checks if the given operator contains the given members.
  bool _hasMember(dynamic expr, Expression m, [Expression? m2]) {
    if (m2 != null) {
      // Binary op.
      return expr.first == m && expr.second == m2;
    } else {
      // Unary op.
      return expr.exp == m;
    }
  }

  /// Checks if given [expr] is a [Variable] and has the given [name].
  bool _isVariable(Expression expr, [String? name]) {
    if (expr is Variable) {
      if (name == null) {
        return true;
      } else {
        return expr.name == name;
      }
    }
    return false;
  }

  Matcher _equalsExpression(String expr, {bool simplify = true}) =>
      ExpressionMatcher(expr, simplify: simplify);
}

/// This matcher compares [Expression]s.
/// It uses a [Lexer] to convert the given expressions to RPN and then checks
/// the token streams for equality.
class ExpressionMatcher extends Matcher {
  final List<Token> _exprRPN;
  final String _expression;
  final bool _simplify;
  static final Lexer _lexer = Lexer();

  /// Creates a new Expression matcher. If [simplify] is true, the expression to
  /// match will be simplified as much as possible beore testing.
  ExpressionMatcher(String expression, {bool simplify = true})
      : this._expression = expression,
        this._exprRPN = _lexer.tokenizeToRPN(expression),
        this._simplify = simplify;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Expression) {
      // Simplify and tokenize.
      Expression expr = _simplify ? _simplifyExp(item) : item;
      String itemStr = expr.toString();
      List<Token> itemRPN = _lexer.tokenizeToRPN(itemStr);

      /*
      print('exprStr: $_expression');
      print('exprTKN: ${_lexer.tokenize(_expression)}');
      print('exprRPN: $_exprRPN');
      print('itemStr: $itemStr');
      print('itemTKN: ${_lexer.tokenize(itemStr)}');
      print('itemRPN: $itemRPN');
      */

      // Save state
      matchState['item'] = itemStr;
      matchState['itemRPN'] = itemRPN;

      // Match with orderedEquals
      return orderedEquals(_exprRPN).matches(itemRPN, matchState);
    }
    return false;
  }

  /// Simplifies the given expression.
  Expression _simplifyExp(Expression exp) {
    String expString;
    Expression expSimplified = exp;
    do {
      expString = expSimplified.toString();
      expSimplified = exp.simplify();
    } while (expString != expSimplified.toString());

    return expSimplified;
  }

  @override
  Description describe(Description description) => description
      .add('expression to match ')
      .addDescriptionOf(_expression)
      .add(' with RPN: ')
      .addDescriptionOf(_exprRPN);

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      !_simplify
          ? mismatchDescription
          : mismatchDescription
              .add('was simplified to ')
              .addDescriptionOf(matchState['state']['item'].toString())
              .add(' with RPN: ')
              .addDescriptionOf(matchState['state']['itemRPN']);
}
