part of math_expressions_test;

/**
 * Contains methods to test the math expression implementation.
 */
class ExpressionTests extends TestSet {
  @override
  String get name => 'Expression Tests';

  @override
  get testFunctions => {
        'Expression creation [REAL]': simpleRealCreation,
        'Expression creation [INTERVAL]': simpleIntervalCreation,
        'Expression Creation [VECTOR]': simpleVectorCreation,
        'Binary Op Convenience creation': convenienceBinaryCreation,
        'Unary Op Convenience creation': convenienceUnaryCreation,
        'Operator simplification': baseOperatorSimplification,
        'Operator differentiation': baseOperatorDifferentiation,
        'Simple evaluation [REAL]': simpleRealEval,
        'Simple evaluation [INTERVAL]': simpleIntervalEval,
        'Simple evaluation [VECTOR]': simpleVectorEval,
        'Default Function creation': defFuncCreation,
        'Default Function simplification': defFuncSimplification,
        'Default Function differentiation': defFuncDifferentiation,
        'Default Function evaluation [REAL]': defFuncRealEval,
        //'Default Function evaluation [INTERVAL]': defFuncIntervalEval,
        //'Default Function evaluation [VECTOR]': defFuncVectorEval,
        'Custom Function creation': cusFuncCreation,
        /*
        'Custom Function simplification': cusFuncSimplification,
        'Custom Function differentiation': cusFuncDifferentiation,
        */
        'Custom Function evaluation [REAL]': cusFuncRealEval,
        /*
        'Custom Function evaluation [INTERVAL]': cusFuncIntervalEval,
        'Custom Function evaluation [VECTOR]': cusFuncVectorEval,
        */
        'Composite Function creation': compFunCreation,
        /*
        'Composite Function simplification': compFuncSimplification,
        'Composite Function differentiation': compFuncDifferentiation,
        'Composite Function evaluation': compFunEval
        */
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
    List<UnaryOperator> unOps = [UnaryMinus('x')];

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

  /// Tests REAL evaluation of basic operators.
  void simpleRealEval() {
    _createBasicExpressions(real);

    double eval = e1.evaluate(real, cm);
    expect(eval, equals(num1 * num2));

    eval = e2.evaluate(real, cm);
    expect(eval, equals(num1 / num2));

    eval = e3.evaluate(real, cm);
    expect(eval, equals(math.pow(num1, num2)));

    eval = e4.evaluate(real, cm);
    expect(eval, equals(num1 + num2));

    eval = e5.evaluate(real, cm);
    expect(eval, equals(num1 - num2));

    eval = e6.evaluate(real, cm);
    expect(eval, equals(-num1));
  }

  /// Tests INTERVAL evaluation of basic operators.
  void simpleIntervalEval() {
    // Interpret REAL as INTERVAL
    _createBasicExpressions(real);

    Interval ri1 = Interval(num1, num1),
        ri2 = Interval(num2, num2),
        ri3 = Interval(num3, num3);

    Interval eval = e1.evaluate(interval, cm);
    expect(eval, equals(ri1 * ri2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(ri1 / ri2));

    //TODO power op on intervals not supported yet
    //eval = e3.evaluate(interval, cm);
    //expect(eval, equals(ri1 ^ ri2));

    eval = e4.evaluate(interval, cm);
    expect(eval, equals(ri1 + ri2));

    eval = e5.evaluate(interval, cm);
    expect(eval, equals(ri1 - ri2));

    eval = e6.evaluate(interval, cm);
    expect(eval, equals(-ri1));

    // Interpret INTERVAL as INTERVAL
    _createBasicExpressions(interval);

    eval = e1.evaluate(interval, cm);
    expect(eval, equals(int1 * int2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(int1 / int2));

    //TODO power op on intervals not supported yet
    //eval = e3.evaluate(interval, cm);
    //expect(eval, equals(i1 ^ i2));

    eval = e4.evaluate(interval, cm);
    expect(eval, equals(int1 + int2));

    eval = e5.evaluate(interval, cm);
    expect(eval, equals(int1 - int2));

    eval = e6.evaluate(interval, cm);
    expect(eval, equals(-int1));
  }

  /// Tests VECTOR evaluation of basic operators.
  void simpleVectorEval() {
    _createBasicExpressions(vector);

    Vector3 vec1 = Vector3.all(num1 as double);
    Vector3 vec2 = Vector3.all(num2 as double);

    Vector3 eval = e1.evaluate(vector, cm);
    vec1.multiply(vec2); // modifies vec1 inplace
    expect(eval, equals(vec1));

    vec1 = Vector3.all(num1 as double);
    eval = e2.evaluate(vector, cm);
    vec1.divide(vec2); // modifies vec1 inplace
    expect(eval, equals(vec1));

    //TODO power op on vectors not supported yet
    //eval = e3.evaluate(vector, cm);
    //expect(eval, equals(math.pow(num1, num2)));

    vec1 = Vector3.all(num1 as double);
    eval = e4.evaluate(vector, cm);
    expect(eval, equals(vec1 + vec2));

    eval = e5.evaluate(vector, cm);
    expect(eval, equals(vec1 - vec2));

    eval = e6.evaluate(vector, cm);
    expect(eval, equals(-vec1));

    // scalars (vector first, then scalar!)
    vec1 = Vector3.all(num1 as double);
    Expression e1_1 = Vector([n1, n1, n1]) * n2;
    eval = e1_1.evaluate(vector, cm);
    expect(eval, equals(vec1 * (num2 as double)));

    vec1 = Vector3.all(num1 as double);
    Expression e1_2 = Vector([n1, n1, n1]) / n2;
    eval = e1_2.evaluate(vector, cm);
    expect(eval, equals(vec1 / (num2 as double)));
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
        Root(5, exp),
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
        Sgn(exp)
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

  /// Tests REAL evaluation of default functions.
  void defFuncRealEval() {
    Number zero, one, two, infinity, negInfty, e, pi;
    zero = Number(0);
    one = Number(1);
    two = Number(2);
    infinity = Number(double.infinity);
    negInfty = Number(double.negativeInfinity);
    pi = Number(math.pi);
    e = Number(math.e);

    /*
     * Exponential
     */
    // 0 -> 1
    double eval = Exponential(zero).evaluate(real, cm);
    expect(eval, equals(1.0));
    // -1 -> 1/e
    eval = Exponential(-one).evaluate(real, cm);
    expect(eval, equals(1.0 / math.e));
    // 1 -> e
    eval = Exponential(one).evaluate(real, cm);
    expect(eval, equals(math.e));
    // INFTY -> INFTY
    eval = Exponential(infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    // -INFTY -> 0.0
    eval = Exponential(negInfty).evaluate(real, cm);
    expect(eval, equals(0.0));

    /*
     * Log
     */
    Number base = Number(2);

    // Log_2(0) -> -INFTY
    eval = Log(base, zero).evaluate(real, cm);
    expect(eval, equals(double.negativeInfinity));
    // Log_2(-1) -> NaN
    eval = Log(base, -one).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // (Nan != NaN) = true
    // Log_2(1) -> 0.0
    eval = Log(base, one).evaluate(real, cm);
    expect(eval, equals(0.0));
    // Log_2(INFTY) -> INFTY
    eval = Log(base, infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    // Log_2(-INFTY) -> INFTY
    eval = Log(base, negInfty).evaluate(real, cm);
    //expect(eval, equals(double.INFINITY)); //TODO check this
    expect(eval, isNot(equals(eval)));

    /*
     * Ln
     */
    // Ln(0) -> -INFTY
    eval = Ln(zero).evaluate(real, cm);
    expect(eval, equals(double.negativeInfinity));
    // Ln(-1) -> NaN
    eval = Ln(-one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // Ln(1) -> 0.0
    eval = Ln(one).evaluate(real, cm);
    expect(eval, equals(0.0));
    // Ln(e) -> 1.0
    eval = Ln(e).evaluate(real, cm);
    expect(eval, equals(1.0));
    // Ln(INFTY) -> 0.0
    eval = Ln(infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    // Ln(-INFTY) -> 0.0
    eval = Ln(negInfty).evaluate(real, cm);
    //expect(eval, equals(double.INFINITY)); //TODO check this
    expect(eval, isNot(equals(eval)));

    /*
     * Cos
     */
    // cos(0) -> 1.0
    eval = Cos(zero).evaluate(real, cm);
    expect(eval, equals(1.0));
    // cos(-1) -> 0.540
    eval = Cos(-one).evaluate(real, cm);
    expect(eval, closeTo(0.540, 0.001));
    // cos(1) -> 0.540
    eval = Cos(one).evaluate(real, cm);
    expect(eval, closeTo(0.540, 0.001));
    // cos(PI) -> -1
    eval = Cos(pi).evaluate(real, cm);
    expect(eval, equals(-1));
    // cos(-PI) -> -1
    eval = Cos(-pi).evaluate(real, cm);
    expect(eval, equals(-1));
    // cos(PI/2) -> 0
    eval = Cos(pi/two).evaluate(real, cm);
    expect(eval, equals(0));
    // cos(INFTY) -> [-1,1] / NaN
    eval = Cos(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // cos(-INFTY) -> [-1,1] / NaN
    eval = Cos(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Sin
     */
    // sin(0) -> 0.0
    eval = Sin(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sin(-1) -> -0.841
    eval = Sin(-one).evaluate(real, cm);
    expect(eval, closeTo(-0.841, 0.001));
    // sin(1) -> 0.841
    eval = Sin(one).evaluate(real, cm);
    expect(eval, closeTo(0.841, 0.001));
    // sin(PI) -> 0
    eval = Sin(pi).evaluate(real, cm);
    expect(eval, equals(0));
    // sin(-PI) -> 0
    eval = Sin(-pi).evaluate(real, cm);
    expect(eval, equals(0));
    // sin(INFTY) -> [-1,1] / NaN
    eval = Sin(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // sin(-INFTY) -> [-1,1] / NaN
    eval = Sin(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Tan
     */
    // tan(0) -> 0.0
    eval = Tan(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // tan(-1) -> -1.55740
    eval = Tan(-one).evaluate(real, cm);
    expect(eval, closeTo(-1.55740, 0.00001));
    // tan(1) -> 1.55740
    eval = Tan(one).evaluate(real, cm);
    expect(eval, closeTo(1.55740, 0.00001));
    // tan(PI) -> 0
    eval = Tan(pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // tan(-PI) -> 0
    eval = Tan(-pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // tan(INFTY) -> <INFTY / NaN
    eval = Tan(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // tan(-INFTY) -> <INFTY / NaN
    eval = Tan(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Asin
     */
    // arcsin(0) = 0
    eval = Asin(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // arcsin(-1) = -π/2
    eval = Asin(-one).evaluate(real, cm);
    expect(eval, closeTo(-math.pi / 2, 0.00001));
    // arcsin(1) = π/2
    eval = Asin(one).evaluate(real, cm);
    expect(eval, closeTo(math.pi / 2, 0.00001));
    // arcsin(2) = NaN
    eval = Asin(Number(2)).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arcsin(-2) = NaN
    eval = Asin(-Number(2)).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arcsin(∞) = -∞
    eval = Asin(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arcsin(-∞) = ∞
    eval = Asin(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Acos
     */
    // arccos(0) = π/2
    eval = Acos(zero).evaluate(real, cm);
    expect(eval, closeTo(math.pi / 2, 0.00001));
    // arccos(-1) = π
    eval = Acos(-one).evaluate(real, cm);
    expect(eval, equals(math.pi));
    // arccos(1) = 0
    eval = Acos(one).evaluate(real, cm);
    expect(eval, equals(0.0));
    // arccos(2) = NaN
    eval = Acos(Number(2)).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arccos(-2) = NaN
    eval = Acos(-Number(2)).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arccos(∞) = -∞
    eval = Acos(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // arccos(-∞) = ∞
    eval = Acos(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Atan
     */
    // arctan(0) = 0
    eval = Atan(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // arctan(-1) = -π/4
    eval = Atan(-one).evaluate(real, cm);
    expect(eval, closeTo(-math.pi / 4, 0.00001));
    // arctan(1) = π/4
    eval = Atan(one).evaluate(real, cm);
    expect(eval, closeTo(math.pi / 4, 0.00001));
    // arctan(∞) = π/2
    eval = Atan(infinity).evaluate(real, cm);
    expect(eval, closeTo(math.pi / 2, 0.00001));
    // arctan(-∞) = -π/2
    eval = Atan(negInfty).evaluate(real, cm);
    expect(eval, closeTo(-math.pi / 2, 0.00001));

    /*
     * Root
     */
    int grade = 5;

    // root_5(0) = 0
    eval = Root(grade, zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // root_5(-1) = NaN
    eval = Root(grade, -one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // root_5(1) = 1
    eval = Root(grade, one).evaluate(real, cm);
    expect(eval, equals(1));
    // root_5(2) = 1.14869
    eval = Root(grade, Number(2)).evaluate(real, cm);
    expect(eval, closeTo(1.14869, 0.00001));
    // root_5(INFTY) -> INFTY
    eval = Root(grade, infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    /*
     *  root_5(-INFTY) -> INFTY
     *  as of IEEE Standard 754-2008 for power function.
     *
     *  TODO  This is inconsistent with Sqrt(-INFTY),
     *        which is Root(2, -INFTY).
     */
    eval = Root(grade, negInfty).evaluate(real, cm);
    expect(eval, equals(double.infinity));

    /*
     * Sqrt
     */
    // sqrt(0) = 0
    eval = Sqrt(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sqrt(-1) = NaN
    eval = Sqrt(-one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // sqrt(1) = 1
    eval = Sqrt(one).evaluate(real, cm);
    expect(eval, equals(1));
    // sqrt(2) = SQRT2
    eval = Sqrt(Number(2)).evaluate(real, cm);
    expect(eval, equals(math.sqrt2));
    // sqrt(INFTY) -> INFTY
    eval = Sqrt(infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    // sqrt(-INFTY) ->  NaN
    eval = Sqrt(negInfty).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));

    /*
     * Abs
     */
    // abs(0) = 0
    eval = Abs(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // abs(-1) = 1
    eval = Abs(-one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // abs(1) = 1
    eval = Abs(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // abs(2) = 2
    eval = Abs(Number(2)).evaluate(real, cm);
    expect(eval, equals(2.0));
    // abs(INFTY) -> INFTY
    eval = Abs(infinity).evaluate(real, cm);
    expect(eval, equals(double.infinity));
    // abs(-INFTY) -> INFTY
    eval = Abs(negInfty).evaluate(real, cm);
    expect(eval, equals(double.infinity));

    /*
     * Sgn
     */
    // sgn(0) = 0
    eval = Sgn(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sgn(-1) = -1
    eval = Sgn(-one).evaluate(real, cm);
    expect(eval, equals(-1.0));
    // sgn(1) = 1
    eval = Sgn(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(2) = 1
    eval = Sgn(Number(2)).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(INFTY) -> 1
    eval = Sgn(infinity).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(-INFTY) -> -1
    eval = Sgn(negInfty).evaluate(real, cm);
    expect(eval, equals(-1.0));

    /*
     * Ceil
     */
    // ceil(0) = 0
    eval = Ceil(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // ceil(-1) = -1
    eval = Ceil(-one).evaluate(real, cm);
    expect(eval, equals(-1.0));
    // ceil(1) = 1
    eval = Ceil(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // ceil(1.5) = 2.0
    eval = Ceil(Number(1.5)).evaluate(real, cm);
    expect(eval, equals(2.0));
    // ceil(∞) = unsupported
    expect(() => Ceil(infinity).evaluate(real, cm),
        throwsA(TypeMatcher<UnsupportedError>()));
    // ceil(-∞) = unsupported
    expect(() => Ceil(negInfty).evaluate(real, cm),
        throwsA(TypeMatcher<UnsupportedError>()));

    /*
     * Floor
     */
    // floor(0) = 0
    eval = Floor(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // floor(-1) = -1
    eval = Floor(-one).evaluate(real, cm);
    expect(eval, equals(-1.0));
    // floor(1) = 1
    eval = Floor(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // floor(1.5) = 1.0
    eval = Floor(Number(1.5)).evaluate(real, cm);
    expect(eval, equals(1.0));
    // floor(∞) = unsupported
    expect(() => Ceil(infinity).evaluate(real, cm),
        throwsA(TypeMatcher<UnsupportedError>()));
    // floor(-∞) = unsupported
    expect(() => Ceil(negInfty).evaluate(real, cm),
        throwsA(TypeMatcher<UnsupportedError>()));
  }

  /// Tests INTERVAL evaluation of default functions.
  void defFuncIntervalEval() {
    throw UnimplementedError();
  }

  /// Tests VECTOR evaluation of default functions.
  void defFuncVectorEval() {
    throw UnimplementedError();
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

  /// Testss REAL evaluation of custom functions: `R^n -> R`
  void cusFuncRealEval() {
    Variable x, y, z;
    CustomFunction cf;
    List<Variable> vars;
    x = Variable('x');
    y = Variable('y');
    z = Variable('z');
    ContextModel cm = ContextModel();

    // Custom SQRT (R -> R)
    vars = [x];
    cf = CustomFunction('sqrt', vars, Sqrt(x));
    cm.bindVariable(x, Number(4));

    expect(cf.evaluate(real, cm), equals(2));

    // Custom ADD (R^2 -> R)
    vars = [x, y];
    cf = CustomFunction('add', vars, x + y);
    cm.bindVariable(y, Number(1));

    expect(cf.evaluate(real, cm), equals(5));

    // Custom Vector LENGTH (R^3 -> R)
    vars = [x, y, z];
    Expression two = Number(2);
    cf =
        CustomFunction('length', vars, Sqrt((x ^ two) + (y ^ two) + (z ^ two)));
    cm..bindVariable(x, two)..bindVariable(y, two)..bindVariable(z, Number(3));

    expect(cf.evaluate(real, cm), closeTo(4.1231, 0.0001));
  }

  /// Testss INTERVAL evaluation of custom functions
  void cusFuncIntervalEval() {
    throw UnimplementedError();
  }

  /// Testss VECTOR evaluation of custom functions
  void cusFuncVectorEval() {
    Variable x, y;
    CustomFunction cf;
    late List<Variable> vars;
    x = Variable('x');
    ContextModel cm = ContextModel();

    // Custom Vector Length
    vars = [x];
    Expression two = Number(2);
    // TODO This doesn't work yet.
    //cf = CustomFunction('length', vars, Sqrt(x[1]^two+x[2]^two));
    cm.bindVariable(x, Vector([Number(2), Number(2)]));

    // TODO Fix this because cf MUST be initialized somehow!
    //expect(cf.evaluate(vector, cm), closeTo(2.82842, 0.00001));
  }

  /// Tests creation of composite functions.
  void compFunCreation() {
    Variable x, y, z;
    late CustomFunction f, g;

    x = Variable('x');
    y = Variable('y');
    z = Variable('z');
    ContextModel cm = ContextModel();

    // Custom FUNKYSPLAT (R -> R^3)
    Expression three = Number(3);
    f = CustomFunction('funkysplat', [x], Vector([x - three, x, x + three]));
    cm.bindVariable(x, three);

    // Should evaluate to a Vector3[0.0,3.0,6.0]
    Vector3 v3 = f.evaluate(vector, cm);
    expect(v3.x, equals(0.0));
    expect(v3.y, equals(3.0));
    expect(v3.z, equals(6.0));

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

    // Should evaluate to the length of v3
    expect(comp.evaluate(real, cm), closeTo(v3.length, 0.0001));

    /*
     * Extended Composite of three functions: R -> R^3 -> R -> R^3
     */
    CompositeFunction comp2 = (comp & f) as CompositeFunction; // = f & g & f

    expect(comp2.domainDimension, equals(1));
    expect(comp2.gDomainDimension, equals(1));
    expect(comp2.f, TypeMatcher<CompositeFunction>());
    expect(comp2.f, equals(comp));
    expect(comp2.g, equals(f));

    // Should evaluate to a Vector3[v3.len-3,v3.len,v3.len+3]
    // Note: Need to use EvaluationType.VECTOR here.
    Vector3 v3_2 = comp2.evaluate(vector, cm);
    expect(v3_2.x, closeTo(v3.length - 3.0, 0.0001));
    expect(v3_2.y, closeTo(v3.length, 0.0001));
    expect(v3_2.z, closeTo(v3.length + 3.0, 0.0001));
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
    // Evaluate composite functions.
    throw UnimplementedError();
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

  Matcher _equalsExpression(String expr, {bool simplify: true}) =>
      ExpressionMatcher(expr, simplify: simplify);
}

/**
 * This matcher compares [Expression]s.
 * It uses a [Lexer] to convert the given expressions to RPN and then checks
 * the token streams for equality.
 */
class ExpressionMatcher extends Matcher {
  final List<Token> _exprRPN;
  final String _expression;
  final bool _simplify;
  static final Lexer _lexer = Lexer();

  /**
   * Creates a new Expression matcher. If [simplify] is true, the expression to
   * match will be simplified as much as possible before testing.
   */
  ExpressionMatcher(String expression, {bool simplify: true})
      : this._expression = expression,
        this._exprRPN = _lexer.tokenizeToRPN(expression),
        this._simplify = simplify;

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
