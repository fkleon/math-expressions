part of math_expressions_test;

/**
 * Contains methods to test the math expression implementation.
 */
class ExpressionTests extends TestSet {

  get name => 'Expression Tests';

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

  void initTests() {
    num1 = 2.25;
    num2 = 5.0;
    num3 = 199.9999999;
    n1 = new Number(num1);
    n2 = new Number(num2);
    n3 = new Number(num3);

    int1 = new Interval(num1, num2);
    int2 = new Interval(num2, num3);
    int3 = new Interval(-num3, num2);

    i1 = new IntervalLiteral(n1, n2);
    i2 = new IntervalLiteral(n2, n3);
    i3 = new IntervalLiteral(-n3, n2);

    v1 = new Vector([n1, n1, n1]);
    v2 = new Vector([n2, n2, n2]);
    v3 = new Vector([n3, n3, n3]);
    //v4 = new Vector([n4, n4, n4]);

    real = EvaluationType.REAL;
    interval = EvaluationType.INTERVAL;
    vector = EvaluationType.VECTOR;

    cm = new ContextModel();
  }

  num num1, num2, num3;
  Interval int1, int2, int3;

  Number n1, n2, n3, n4;
  IntervalLiteral i1, i2, i3;
  Vector v1, v2, v3;
  Expression e1, e2, e3, e4, e5, e6;

  EvaluationType real, interval, vector;
  ContextModel cm;

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
    List<BinaryOperator> binOps = [new Times('x', 2),
                                   new Divide('x', 2),
                                   new Plus('x', 2),
                                   new Minus('x', 2),
                                   new Power('x', 2)];

    for (BinaryOperator binOp in binOps) {
      expect(binOp.first, new isInstanceOf<Variable>());
      expect(binOp.second, new isInstanceOf<Number>());
    }
  }

  /// Tests the convenience constructors (unary, auto-wrapping).
  void convenienceUnaryCreation() {
    List<UnaryOperator> unOps = [new UnaryMinus('x')];

    for (UnaryOperator unOp in unOps) {
      expect(unOp.exp, new isInstanceOf<Variable>());
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
    Expression exp = new Plus('a', 0);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 0 + a = a
    exp = new Plus(0, 'a');
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // a + -(b) = a - b
    exp = new Plus('a', new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<Minus>());
    expect((exp.simplify() as Minus).first, new isInstanceOf<Variable>());
    expect((exp.simplify() as Minus).second, new isInstanceOf<Variable>());

    /*
     *  Minus
     */
    // a - 0 = a
    exp = new Minus('a', 0);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 0 - a = - a
    exp = new Minus(0, 'a');
    expect(exp.simplify(), new isInstanceOf<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, new isInstanceOf<Variable>());

    // a - -(b) = a + b
    exp = new Minus('a', new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<Plus>());
    expect((exp.simplify() as Plus).first, new isInstanceOf<Variable>());
    expect((exp.simplify() as Plus).second, new isInstanceOf<Variable>());

    /*
     *  Times
     */
    // -a * b = - (a * b)
    exp = new Times(new UnaryMinus('a'), 'b');
    expect(exp.simplify(), new isInstanceOf<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, new isInstanceOf<Times>());
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Times).first, 'a'), isTrue);
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Times).second, 'b'), isTrue);

    // a * -b = - (a * b)
    exp = new Times('a', new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, new isInstanceOf<Times>());
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Times).first, 'a'), isTrue);
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Times).second, 'b'), isTrue);

    // -a * -b = a * b
    exp = new Times(new UnaryMinus('a'), new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<Times>());
    expect(_isVariable((exp.simplify() as Times).first, 'a'), isTrue);
    expect(_isVariable((exp.simplify() as Times).second, 'b'), isTrue);

    // a * 0 = 0
    exp = new Times(new UnaryMinus('a'), 0);
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // 0 * a = 0
    exp = new Times(0, new Variable('a'));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // a * 1 = a
    exp = new Times(new Variable('a'), 1);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // 1 * a = a
    exp = new Times(1, new Variable('a'));
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    /*
     *  Divide
     */
    // -a / b = - (a / b)
    exp = new Divide(new UnaryMinus('a'), 'b');
    expect(exp.simplify(), new isInstanceOf<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, new isInstanceOf<Divide>());
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Divide).first, 'a'), isTrue);
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Divide).second, 'b'), isTrue);

    // a * -b = - (a / b)
    exp = new Divide('a', new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<UnaryMinus>());
    expect((exp.simplify() as UnaryMinus).exp, new isInstanceOf<Divide>());
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Divide).first, 'a'), isTrue);
    expect(_isVariable(((exp.simplify() as UnaryMinus).exp as Divide).second, 'b'), isTrue);

    // -a / -b = a / b
    exp = new Divide(new UnaryMinus('a'), new UnaryMinus('b'));
    expect(exp.simplify(), new isInstanceOf<Divide>());
    expect(_isVariable((exp.simplify() as Divide).first, 'a'), isTrue);
    expect(_isVariable((exp.simplify() as Divide).second, 'b'), isTrue);

    // 0 / a = 0
    exp = new Divide(0, new Variable('a'));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // a / 1 = a
    exp = new Divide(new Variable('a'), 1);
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    /*
     *  Power
     */
    // 0^x = 0
    exp = new Power(0, 'x');
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // 1^x = 1
    exp = new Power(1, 'x');
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // x^0 = 1
    exp = new Power('x', 0);
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // x^1 = x
    exp = new Power('x', 1);
    expect(_isVariable(exp.simplify(), 'x'), isTrue);

    /*
     *  Unary Minus
     */
    // -(-a) = a
    exp = new UnaryMinus(new UnaryMinus('a'));
    expect(_isVariable(exp.simplify(), 'a'), isTrue);

    // -0 = 0
    exp = new UnaryMinus(0);
    expect((exp.simplify() as Number).value == 0, isTrue);
  }

  /// Tests differentiation of bsaic operators.
  void baseOperatorDifferentiation() {
    var diff = [
                 // Expression,         deriveTo, output,     outputSimplified
                 [new Plus (1, 'x'),    'x',      '0.0+1.0',  '1.0'],
                 [new Plus (1, 1),      'x',      '0.0+0.0',  '0.0'],
                 [new Minus (1, 'x') ,  'x',      '0.0-1.0',  '-1.0'],
                 [new Minus ('x', 1) ,  'x',      '1.0-0.0',  '1.0'],
                 [new Times('x', 1),    'x',      'x*0.0+1.0*1.0',  '1.0'],
                 [new Divide('x',2),    'x',      '((1.0*2.0)-(x*0.0))/(2.0*2.0)',
                  '2.0/(2.0*2.0)'],
                 [new Modulo('x', 'x'), 'x',
                  '1.0 - floor(x / abs(x)) * (sgn(x) * 1.0)',
                  '1.0 - floor(x / abs(x)) * sgn(x)'],
                 [new Power('x',2),     'x',      'exp(2.0 * ln(x)) * ((2.0 * (1.0 / x)) + (0.0 * ln(x)))',
                  'x^2.0 * (2.0 * (1.0 / x))'],
                ];


    for (List exprCase in diff) {
      Expression exp = exprCase[0];
      String deriveTo = exprCase[1];
      String expected = exprCase[2];
      String expectedSimpl = exprCase[3];
      expect(exp.derive(deriveTo), _equalsExpression(expected, simplify:false));
      expect(exp.derive(deriveTo), _equalsExpression(expectedSimpl));
    }
  }

  /// Tests REAL evaluation of basic operators.
  void simpleRealEval() {
    _createBasicExpressions(real);

    var eval = e1.evaluate(real, cm);
    expect(eval, equals(num1 * num2));

    eval = e2.evaluate(real, cm);
    expect(eval, equals(num1 / num2));

    eval = e3.evaluate(real, cm);
    expect(eval, equals(Math.pow(num1, num2)));

    eval = e4.evaluate(real, cm);
    expect(eval, equals(num1 + num2));

    eval = e5.evaluate(real, cm);
    expect(eval, equals(num1 - num2));

    eval = e6.evaluate(real, cm);
    expect(eval, equals(- num1));
  }

  /// Tests INTERVAL evaluation of basic operators.
  void simpleIntervalEval() {
    // Interpret REAL as INTERVAL
    _createBasicExpressions(real);

    Interval ri1 = new Interval(num1, num1),
             ri2 = new Interval(num2, num2),
             ri3 = new Interval(num3, num3);

    var eval = e1.evaluate(interval, cm);
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
    expect(eval, equals(- ri1));

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
    expect(eval, equals(- int1));
  }

  /// Tests VECTOR evaluation of basic operators.
  void simpleVectorEval() {
    _createBasicExpressions(vector);

    Vector3 vec1 = new Vector3.all(num1);
    Vector3 vec2 = new Vector3.all(num2);

    var eval = e1.evaluate(vector, cm);
    expect(eval, equals(vec1.multiply(vec2))); // modifies vec1

    vec1 = new Vector3.all(num1);
    eval = e2.evaluate(vector, cm);
    expect(eval, equals(vec1.divide(vec2))); // modifies vec1

    //TODO power op on vectors not supported yet
    //eval = e3.evaluate(vector, cm);
    //expect(eval, equals(Math.pow(num1, num2)));

    vec1 = new Vector3.all(num1);
    eval = e4.evaluate(vector, cm);
    expect(eval, equals(vec1 + vec2));

    eval = e5.evaluate(vector, cm);
    expect(eval, equals(vec1 - vec2));

    eval = e6.evaluate(vector, cm);
    expect(eval, equals(- vec1));

    // scalars (vector first, then scalar!)
    vec1 = new Vector3.all(num1);
    Expression e1_1 = new Vector([n1, n1, n1]) * n2;
    eval = e1_1.evaluate(vector, cm);
    expect(eval, equals(vec1 * num2));

    vec1 = new Vector3.all(num1);
    Expression e1_2 = new Vector([n1, n1, n1]) / n2;
    eval = e1_2.evaluate(vector, cm);
    expect(eval, equals(vec1 / num2));
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
      expect(fun.args, anyElement(new isInstanceOf<BoundVariable>()));
    }

    // Test with variable
    exp = new Variable('x');
    functions = _createDefaultFunctions(exp);

    for (MathFunction fun in functions) {
      // Variables should not get boxed, test for contains
      expect(fun.args, contains(exp));
    }
  }

  /// Helper function to create a list of all default functions.
  List<MathFunction> _createDefaultFunctions(Expression exp) {
    return [new Cos(exp),
            new Exponential(exp),
            new Log(exp, exp),
            new Ln(exp),
            new Root(5, exp),
            new Root.sqrt(exp),
            new Sqrt(exp),
            new Sin(exp),
            new Tan(exp),
            new Abs(exp),
            new Sgn(exp)];
  }

  /// Tests simplification of default functions.
  void defFuncSimplification() {
    /*
     *  Exponential
     */
    // e^0 = 1
    Expression exp = new Exponential(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    // e^1 = e
    exp = new Exponential(new Number(1));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == Math.E, isTrue);

    // e^(x*ln(y)) = y^x
    exp = new Exponential(new Variable('x') * new Ln(new Variable('y')));
    expect(exp.simplify(), new isInstanceOf<Power>());
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
    exp = new Ln(new Number(1));
    expect(exp.simplify(), new isInstanceOf<Number>());
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
    exp = new Sqrt(new Power('x', 2));
    expect(_isVariable(exp.simplify(), 'x'), isTrue);

    // sqrt(0) = 0
    exp = new Sqrt(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    // sqrt(1) = 1
    exp = new Sqrt(new Number(1));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    /*
     * Sin
     */
    // sin(0) = 0
    exp = new Sin(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     * Cos
     */
    // cos(0) = 1
    exp = new Cos(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 1, isTrue);

    /*
     * Tan
     */
    // tan(0) = 0
    exp = new Tan(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Number>());
    expect((exp.simplify() as Number).value == 0, isTrue);

    /*
     * Abs
     */
    exp = new Abs(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Abs>());
    expect((exp.simplify() as Abs).arg, new isInstanceOf<BoundVariable>());

    /*
     * Ceil
     */
    exp = new Ceil(new Floor(new Variable("x")));
    expect((exp.simplify() as Floor).arg, new isInstanceOf<Variable>());

    /*
     * Floor
     */
    exp = new Floor(new Ceil(new Variable("x")));
    expect((exp.simplify() as Ceil).arg, new isInstanceOf<Variable>());

    /*
     * Sgn
     */
    exp = new Sgn(new Number(0));
    expect(exp.simplify(), new isInstanceOf<Sgn>());
    expect((exp.simplify() as Sgn).arg, new isInstanceOf<BoundVariable>());
  }

  /// Tests differentiation of default functions.
  void defFuncDifferentiation() {
    Variable x = new Variable('x');
    Number two = new Number(2);
    var diff = [
                 // Expression,  deriveTo, output, outputSimplified
                 [new Exponential(x), 'x',
                                      'exp(x) * 1.0',
                                      'exp(x)'],
                 [new Ln(x),          'x',
                                      '1.0 / x',
                                      '1.0 / x'],
                 // TODO Simplify can't cancel out terms yet, so the
                 //      simplified version is still a but ugly:
                 [new Log(two, x),    'x',
                                      '((((1.0 / x) * ln(2.0)) - (ln(x) * (0.0 / 2.0))) / (ln(2.0) * ln(2.0)))',
                                      '(((1.0 / x) * ln(2.0)) / (ln(2.0) * ln(2.0)))'],
                                      //'1.0 / (x * ln(2.0))'],

                 // TODO Roots are internally handled as Powers:
                 //[new Sqrt(x),        'x', '0.0', '0.0'],
                 //[new Root(2, x),     'x', '0.0', '0.0'],

                 [new Sin(x),         'x', 'cos(x) * 1.0',  'cos(x)'],
                 [new Cos(x),         'x', '-sin(x) * 1.0', '-sin(x)'],

                 // TODO Tan is internally handled as sin/cos:
                 //[new Tan(x),          'x', '0.0',    '0.0']

                 [new Abs(x),         'x', 'sgn(x) * 1.0', 'sgn(x)'],
                 [new Abs(two * x),   'x',
                                      'sgn(2.0 * x) * (2.0 * 1.0 + 0.0 * x)',
                                      'sgn(2.0 * x) * 2.0']
                ];

    for (List exprCase in diff) {
      Expression exp = exprCase[0];
      String deriveTo = exprCase[1];
      String expected = exprCase[2];
      String expectedSimpl = exprCase[3];
      expect(exp.derive(deriveTo), _equalsExpression(expected, simplify:false));
      expect(exp.derive(deriveTo), _equalsExpression(expectedSimpl));
    }
  }

  /// Tests REAL evaluation of default functions.
  void defFuncRealEval() {

    Number zero, one, infinity, negInfty, e, pi ;
    zero = new Number(0);
    one = new Number(1);
    infinity = new Number(double.INFINITY);
    negInfty = new Number(double.NEGATIVE_INFINITY);
    pi = new Number(Math.PI);
    e = new Number(Math.E);

    /*
     * Exponential
     */
    // 0 -> 1
    double eval = new Exponential(zero).evaluate(real, cm);
    expect(eval, equals(1.0));
    // -1 -> 1/e
    eval = new Exponential(-one).evaluate(real, cm);
    expect(eval, equals(1.0/Math.E));
    // 1 -> e
    eval = new Exponential(one).evaluate(real, cm);
    expect(eval, equals(Math.E));
    // INFTY -> INFTY
    eval = new Exponential(infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    // -INFTY -> 0.0
    eval = new Exponential(-infinity).evaluate(real, cm);
    expect(eval, equals(0.0));

    /*
     * Log
     */
    Number base = new Number(2);

    // Log_2(0) -> -INFTY
    eval = new Log(base, zero).evaluate(real, cm);
    expect(eval, equals(double.NEGATIVE_INFINITY));
    // Log_2(-1) -> NaN
    eval = new Log(base, -one).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // (Nan != NaN) = true
    // Log_2(1) -> 0.0
    eval = new Log(base, one).evaluate(real, cm);
    expect(eval, equals(0.0));
    // Log_2(INFTY) -> INFTY
    eval = new Log(base, infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    // Log_2(-INFTY) -> INFTY
    eval = new Log(base,negInfty).evaluate(real, cm);
    //expect(eval, equals(double.INFINITY)); //TODO check this
    expect(eval, isNot(equals(eval)));

    /*
     * Ln
     */
    // Ln(0) -> -INFTY
    eval = new Ln(zero).evaluate(real, cm);
    expect(eval, equals(double.NEGATIVE_INFINITY));
    // Ln(-1) -> NaN
    eval = new Ln(-one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // Ln(1) -> 0.0
    eval = new Ln(one).evaluate(real, cm);
    expect(eval, equals(0.0));
    // Ln(e) -> 1.0
    eval = new Ln(e).evaluate(real, cm);
    expect(eval, equals(1.0));
    // Ln(INFTY) -> 0.0
    eval = new Ln(infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    // Ln(-INFTY) -> 0.0
    eval = new Ln(negInfty).evaluate(real, cm);
    //expect(eval, equals(double.INFINITY)); //TODO check this
    expect(eval, isNot(equals(eval)));

    /*
     * Cos
     */
    // cos(0) -> 1.0
    eval = new Cos(zero).evaluate(real, cm);
    expect(eval, equals(1.0));
    // cos(-1) -> 0.540
    eval = new Cos(-one).evaluate(real, cm);
    expect(eval, closeTo(0.540, 0.001));
    // cos(1) -> 0.540
    eval = new Cos(one).evaluate(real, cm);
    expect(eval, closeTo(0.540, 0.001));
    // cos(PI) -> -1
    eval = new Cos(pi).evaluate(real, cm);
    expect(eval, equals(-1));
    // cos(-PI) -> -1
    eval = new Cos(-pi).evaluate(real, cm);
    expect(eval, equals(-1));
    // cos(INFTY) -> [-1,1] / NaN
    eval = new Cos(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // cos(-INFTY) -> [-1,1] / NaN
    eval = new Cos(-infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Sin
     */
    // sin(0) -> 0.0
    eval = new Sin(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sin(-1) -> -0.841
    eval = new Sin(-one).evaluate(real, cm);
    expect(eval, closeTo(-0.841, 0.001));
    // sin(1) -> 0.841
    eval = new Sin(one).evaluate(real, cm);
    expect(eval, closeTo(0.841, 0.001));
    // sin(PI) -> 0
    eval = new Sin(pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // sin(-PI) -> 0
    eval = new Sin(-pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // sin(INFTY) -> [-1,1] / NaN
    eval = new Sin(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // sin(-INFTY) -> [-1,1] / NaN
    eval = new Sin(-infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Tan
     */
    // tan(0) -> 0.0
    eval = new Tan(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // tan(-1) -> -1.55740
    eval = new Tan(-one).evaluate(real, cm);
    expect(eval, closeTo(-1.55740, 0.00001));
    // tan(1) -> 1.55740
    eval = new Tan(one).evaluate(real, cm);
    expect(eval, closeTo(1.55740, 0.00001));
    // tan(PI) -> 0
    eval = new Tan(pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // tan(-PI) -> 0
    eval = new Tan(-pi).evaluate(real, cm);
    expect(eval, closeTo(0, 0.00001));
    // tan(INFTY) -> <INFTY / NaN
    eval = new Tan(infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN
    // tan(-INFTY) -> <INFTY / NaN
    eval = new Tan(-infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval))); // NaN

    /*
     * Root
     */
    int grade = 5;

    // root_5(0) = 0
    eval = new Root(grade, zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // root_5(-1) = NaN
    eval = new Root(grade, -one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // root_5(1) = 1
    eval = new Root(grade, one).evaluate(real, cm);
    expect(eval, equals(1));
    // root_5(2) = 1.14869
    eval = new Root(grade, new Number(2)).evaluate(real, cm);
    expect(eval, closeTo(1.14869, 0.00001));
    // root_5(INFTY) -> INFTY
    eval = new Root(grade, infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    /*
     *  root_5(-INFTY) -> INFTY
     *  as of IEEE Standard 754-2008 for power function.
     *
     *  TODO  This is inconsistent with Sqrt(-INFTY),
     *        which is Root(2, -INFTY).
     */
    eval = new Root(grade, -infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));

    /*
     * Sqrt
     */
    // sqrt(0) = 0
    eval = new Sqrt(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sqrt(-1) = NaN
    eval = new Sqrt(-one).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));
    // sqrt(1) = 1
    eval = new Sqrt(one).evaluate(real, cm);
    expect(eval, equals(1));
    // sqrt(2) = SQRT2
    eval = new Sqrt(new Number(2)).evaluate(real, cm);
    expect(eval, equals(Math.SQRT2));
    // sqrt(INFTY) -> INFTY
    eval = new Sqrt(infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    // sqrt(-INFTY) ->  NaN
    eval = new Sqrt(-infinity).evaluate(real, cm);
    expect(eval, isNot(equals(eval)));

    /*
     * Abs
     */
    // abs(0) = 0
    eval = new Abs(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // abs(-1) = 1
    eval = new Abs(-one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // abs(1) = 1
    eval = new Abs(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // abs(2) = 2
    eval = new Abs(new Number(2)).evaluate(real, cm);
    expect(eval, equals(2.0));
    // abs(INFTY) -> INFTY
    eval = new Abs(infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));
    // abs(-INFTY) -> INFTY
    eval = new Abs(-infinity).evaluate(real, cm);
    expect(eval, equals(double.INFINITY));

    /*
     * Sgn
     */
    // sgn(0) = 0
    eval = new Sgn(zero).evaluate(real, cm);
    expect(eval, equals(0.0));
    // sgn(-1) = -1
    eval = new Sgn(-one).evaluate(real, cm);
    expect(eval, equals(-1.0));
    // sgn(1) = 1
    eval = new Sgn(one).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(2) = 1
    eval = new Sgn(new Number(2)).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(INFTY) -> 1
    eval = new Sgn(infinity).evaluate(real, cm);
    expect(eval, equals(1.0));
    // sgn(-INFTY) -> -1
    eval = new Sgn(-infinity).evaluate(real, cm);
    expect(eval, equals(-1.0));
  }

  /// Tests INTERVAL evaluation of default functions.
  void defFuncIntervalEval() {
    throw new UnimplementedError();
  }

  /// Tests VECTOR evaluation of default functions.
  void defFuncVectorEval() {
    throw new UnimplementedError();
  }

  /// Tests creation of custom functions.
  void cusFuncCreation() {
    // Create some custom functions.
    Variable x = new Variable("x");
    List<Variable> vars = [x];
    CustomFunction cf = new CustomFunction("sqrt", vars, new Sqrt(x));

    expect(cf.domainDimension, equals(vars.length));
    expect(cf.expression, new isInstanceOf<Sqrt>());

    //TODO more tests.
  }

  /// Tests simplification of custom functions.
  void cusFuncSimplification() {
    throw new UnimplementedError();
  }

  /// Tests differentiation of custom functions.
  void cusFuncDifferentiation() {
    throw new UnimplementedError();
  }

  /// Testss REAL evaluation of custom functions: `R^n -> R`
  void cusFuncRealEval() {
    Variable x,y,z;
    CustomFunction cf;
    List<Variable> vars;
    x = new Variable("x");
    y = new Variable("y");
    z = new Variable("z");
    ContextModel cm = new ContextModel();

    // Custom SQRT (R -> R)
    vars = [x];
    cf = new CustomFunction("sqrt", vars, new Sqrt(x));
    cm.bindVariable(x, new Number(4));

    expect(cf.evaluate(real, cm), equals(2));

    // Custom ADD (R^2 -> R)
    vars = [x, y];
    cf = new CustomFunction("add", vars, x+y);
    cm.bindVariable(y, new Number(1));

    expect(cf.evaluate(real, cm), equals(5));

    // Custom Vector LENGTH (R^3 -> R)
    vars = [x, y, z];
    Expression two = new Number(2);
    cf = new CustomFunction("length", vars, new Sqrt((x^two)+(y^two)+(z^two)));
    cm.bindVariable(x, two);
    cm.bindVariable(y, two);
    cm.bindVariable(z, new Number(3));

    expect(cf.evaluate(real, cm), closeTo(4.1231, 0.0001));
  }

  /// Testss INTERVAL evaluation of custom functions
  void cusFuncIntervalEval() {
    throw new UnimplementedError();
  }

  /// Testss VECTOR evaluation of custom functions
  void cusFuncVectorEval() {
    Variable x,y;
    CustomFunction cf;
    List<Variable> vars;
    x = new Variable("x");
    ContextModel cm = new ContextModel();

    // Custom Vector Length
    vars = [x];
    Expression two = new Number(2);
    // TODO This doesn't work yet.
    //cf = new CustomFunction("length", vars, new Sqrt(x[1]^two+x[2]^two));
    cm.bindVariable(x, new Vector([new Number(2), new Number(2)]));

    expect(cf.evaluate(vector, cm), closeTo(2.82842, 0.00001));
  }

  /// Tests creation of composite functions.
  void compFunCreation() {
    Variable x, y, z;
    CustomFunction f, g;

    x = new Variable("x");
    y = new Variable("y");
    z = new Variable("z");
    ContextModel cm = new ContextModel();

    // Custom FUNKYSPLAT (R -> R^3)
    Expression three = new Number(3);
    f = new CustomFunction("funkysplat", [x], new Vector([x-three,x,x+three]));
    cm.bindVariable(x, three);

    // Should evaluate to a Vector3[0.0,3.0,6.0]
    Vector3 v3 = f.evaluate(vector, cm);
    expect(v3.x, equals(0.0));
    expect(v3.y, equals(3.0));
    expect(v3.z, equals(6.0));

    // Custom Vector LENGTH (R^3 -> R)
    Expression two = new Number(2);
    g = new CustomFunction("length", [x, y, z], new Sqrt((x^two)+(y^two)+(z^two)));

    /*
     * Simple Composite of two functions: R -> R^3 -> R
     */
    CompositeFunction comp = f & g;

    expect(comp.domainDimension, equals(1));
    expect(comp.gDomainDimension, equals(3));
    expect(comp.f, equals(f));
    expect(comp.g, equals(g));

    // Should evaluate to the length of v3
    expect(comp.evaluate(real, cm), closeTo(v3.length, 0.0001));

    /*
     * Extended Composite of three functions: R -> R^3 -> R -> R^3
     */
    CompositeFunction comp2 = comp & f; // = f & g & f

    expect(comp2.domainDimension, equals(1));
    expect(comp2.gDomainDimension, equals(1));
    expect(comp2.f, new isInstanceOf<CompositeFunction>());
    expect(comp2.f, equals(comp));
    expect(comp2.g, equals(f));

    // Should evaluate to a Vector3[v3.len-3,v3.len,v3.len+3]
    // Note: Need to use EvaluationType.VECTOR here.
    Vector3 v3_2 = comp2.evaluate(vector, cm);
    expect(v3_2.x, closeTo(v3.length-3.0, 0.0001));
    expect(v3_2.y, closeTo(v3.length, 0.0001));
    expect(v3_2.z, closeTo(v3.length+3.0, 0.0001));
  }

  /// Tests simplification of composite functions.
  void compFuncSimplification() {
    throw new UnimplementedError();
  }

  /// Tests differentiation of composite functions.
  void compFuncDifferentiation() {
    throw new UnimplementedError();
  }

  /// Tests evaluation of composite functions.
  void compFunEval() {
    // Evaluate composite functions.
    throw new UnimplementedError();
  }

  /// Checks if the given operator contains the given members.
  bool _hasMember(expr, m, [m2]) {
    if (m2 != null) {
      // Binary op.
      return expr.first == m && expr.second == m2;
    } else {
      // Unary op.
      return expr.exp == m;
    }
  }

  /// Checks if given [expr] is a [Variable] and has the given [name].
  bool _isVariable(expr, [name]) {
    if (expr is Variable) {
      if (name == null) {
        return true;
      } else {
        return expr.name == name;
      }
    }
    return false;
  }

  Matcher _equalsExpression(String expr, {simplify: true}) => new ExpressionMatcher(expr, simplify:simplify);
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
  static final Lexer _lexer = new Lexer();

  /**
   * Creates a new Expression matcher. If [simplify] is true, the expression to
   * match will be simplified as much as possible before testing.
   */
  ExpressionMatcher(String expression, {simplify: true}):
      this._expression = expression,
      this._exprRPN = _lexer.tokenizeToRPN(expression),
      this._simplify = simplify;

  bool matches(item, Map matchState) {
    if (item is Expression) {
      // Simplify and tokenize.
      Expression expr = _simplify ? _simplifyExp(item) : item;
      String itemStr = expr.toString();
      List<Token> itemRPN = _lexer.tokenizeToRPN(itemStr);

      /*
      print("exprStr: $_expression");
      print("exprTKN: ${_lexer.tokenize(_expression)}");
      print("exprRPN: $_exprRPN");
      print("itemStr: $itemStr");
      print("itemTKN: ${_lexer.tokenize(itemStr)}");
      print("itemRPN: $itemRPN");
      */

      // Save state
      matchState["item"] = itemStr;
      matchState["itemRPN"] = itemRPN;

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

  Description describe(Description description) =>
      description.add("expression to match ")
        .addDescriptionOf(_expression)
        .add(' with RPN: ')
        .addDescriptionOf(_exprRPN);

  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) =>
      !_simplify ? mismatchDescription :
        mismatchDescription.add("was simplified to ")
        .addDescriptionOf(matchState["state"]["item"].toString())
        .add(' with RPN: ')
        .addDescriptionOf(matchState["state"]["itemRPN"]);
}
