part of math_expressions_test;

/**
 * Contains methods to test the math expression implementation.
 */
class ExpressionTests extends TestSet {

  get name => 'Expression Tests';

  get testFunctions => {
    'Expression Creation [REAL]': simpleRealCreation,
    'Expression Creation [INTERVAL]': simpleIntervalCreation,
    //'Expression Creation [VECTOR]': simpleVectorCreation,
    'Binary Op Convenience Creation': convenienceBinaryCreation,
    'Unary Op Convenience Creation': convenienceUnaryCreation,
    'Operator simplification': baseOperatorSimplification,
    'Operator differentiation': baseOperatorDifferentiation,
    'Simple evaluation [REAL]': simpleRealEval,
    'Simple evaluation [INTERVAL]': simpleIntervalEval,
    //'Simple evaluation [VECTOR]': simpleVectorEval,
    'Default Function Creation': defFuncCreation,
    'Default Function simplification': defFuncSimplification,
    'Default Function differentiation': defFuncDifferentiation,
    'Default Function evaluation [REAL]': defFuncRealEval,
    //'Default Function evaluation [INTERVAL]': defFuncIntervalEval,
    //'Default Function evaluation [VECTOR]': defFuncVectorEval,
    /*
    'Custom Function Creation': cusFuncCreation,
    'Custom Function simplification': cusFuncSimplification,
    'Custom Function differentiation': cusFuncDifferentiation,
    'Custom Function evaluation [REAL]': cusFuncRealEval,
    'Custom Function evaluation [INTERVAL]': cusFuncIntervalEval,
    'Custom Function evaluation [VECTOR]': cusFuncVectorEval,
    'Composite Function creation': compFunCreation,
    'Composite Function simplification': compFuncSimplification,
    'Composite Function differentiation': compFuncDifferentiation,
    'Composite Function evaluation': compFunEval
    */
  };

  void initTests() {
    num1 = 2.25;
    num2 = 5;
    num3 = 199.9999999;
    n1 = new Number(num1);
    n2 = new Number(num2);
    n3 = new Number(num3);

    int1 = new Interval(num1, num2);
    int2 = new Interval(num2, num3);
    int3 = new Interval(-num3, num2);;

    i1 = new IntervalLiteral(n1, n2);
    i2 = new IntervalLiteral(n2, n3);
    i3 = new IntervalLiteral(-n3, n2);

    real = EvaluationType.REAL;
    interval = EvaluationType.INTERVAL;
    vector = EvaluationType.VECTOR;

    cm = new ContextModel();
  }

  num num1, num2, num3;
  Interval int1, int2, int3;

  Number n1, n2, n3, n4;
  IntervalLiteral i1, i2, i3;
  Variable v1, v2, v3;
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
      //e3 = i1 ^ i2;
      e4 = i1 + i2;
      e5 = i1 - i2;
      e6 = -i1;
      return;
    }

    if (type == EvaluationType.VECTOR) {
      //TODO vector
    }
  }

  /// Test the constructors of expressions.
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

  /// Test the convenience constructors (binary, auto-wrapping).
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
  
  /// Test the convenience constructors (unary, auto-wrapping).
  void convenienceUnaryCreation() {
    List<UnaryOperator> unOps = [new UnaryMinus('x')]; 
    
    for (UnaryOperator unOp in unOps) {
      expect(unOp.exp, new isInstanceOf<Variable>());
    }
  }
  
  /// Test the constructors.
  void simpleIntervalCreation() {
    _createBasicExpressions(interval);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, i1, i2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, i1, i2), isTrue);

    // no power OP on intervals yet
//    expect(e3 is Power, isTrue);
//    expect(_hasMember(e3, i1, i2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, i1, i2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, i1, i2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, i1), isTrue);
  }

  /// Test the constructors.
  void simpleVectorCreation() {
    _createBasicExpressions(vector);

    //TODO vector
    throw new UnimplementedError();
  }
  
  /// Test simplification of expressions.
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
  
  void baseOperatorDifferentiation() {
    var diff = [
                 // Expression,         deriveTo, output,     outputSimplified
                 [new Plus (1, 'x'),    'x',      '0.0+1.0',  '1.0'],
                 [new Plus (1, 1),      'x',      '0.0+0.0',  '0.0'],
                 [new Minus (1, 'x') ,  'x',      '0.0-1.0',  '(-1.0)'],
                 [new Minus ('x', 1) ,  'x',      '1.0-0.0',  '1.0'],
                 [new Times('x', 1),    'x',      'x*0.0+1.0*1.0',  '1.0'],
                 [new Divide('x',2),    'x',      '((1.0*2.0)-(x*0.0))/(2.0*2.0)',
                  '2.0/(2.0*2.0)'],
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
  
  void simpleRealEval() {
    _createBasicExpressions(real);

    var eval = e1.evaluate(real, cm);
    expect(eval, equals(num1 * num2));

    eval = e2.evaluate(real, cm);
    expect(eval, equals(num1 / num2));

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

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(ri1 / ri2));

    //TODO
//    eval = e3.evaluate(interval, cm);
//    expect(eval, equals(ri1 ^ ri2));

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

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(int1 / int2));

    //TODO
//    eval = e3.evaluate(interval, cm);
//    expect(eval, equals(i1 ^ i2));

    eval = e4.evaluate(interval, cm);
    expect(eval, equals(int1 + int2));

    eval = e5.evaluate(interval, cm);
    expect(eval, equals(int1 - int2));

    eval = e6.evaluate(interval, cm);
    expect(eval, equals(- int1));
  }

  void simpleVectorEval() {
    // TODO test eval
    throw new UnimplementedError();
  }

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
  
  List<MathFunction> _createDefaultFunctions(Expression exp) {
    return [new Cos(exp),
            new Exponential(exp),
            new Log(exp, exp),
            new Ln(exp),
            new Root(5, exp),
            new Root.sqrt(exp),
            new Sqrt(exp),
            new Sin(exp),
            new Tan(exp)];
  }
  
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
  }
  
  void defFuncDifferentiation() {
    Variable x = new Variable('x');
    Number base = new Number(2);
    var diff = [
                 // Expression,  deriveTo, output, outputSimplified
                 [new Exponential(x), 'x', 'exp(x) * 1.0',  'exp(x)'],
                 [new Ln(x),          'x', '1.0 / x',       '1.0 / x'],
                 //[new Log(base, x),   'x', '1.0 / (x * log(2.0))', '1.0 / (x * log(2.0))'],
                 //[new Sqrt(x),        'x', '0.0', '0.0'],
                 //[new Root(2, x),     'x', '0.0', '0.0'],
                 //[new Sin(x),         'x', 'cos(x)',  'cos(x)'], //TODO parser can't handle output
                 //[new Cos(x),         'x', '-sin(x)', '-sin(x)'], //TODO parser can't handle output
                 //[new Tan(x),          'x', '0.0',    '0.0']
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
  }

  void defFuncIntervalEval() {
    throw new UnimplementedError();
  }

  void defFuncVectorEval() {
    throw new UnimplementedError();
  }

  void cusFuncCreation() {
    // Create some custom functions.
    throw new UnimplementedError();
  }
  
  void cusFuncSimplification() {
    throw new UnimplementedError();
  }
  
  void cusFuncDifferentiation() {
    throw new UnimplementedError();
  }

  void cusFuncRealEval() {
    throw new UnimplementedError();
  }

  void cusFuncIntervalEval() {
    throw new UnimplementedError();
  }

  void cusFuncVectorEval() {
    throw new UnimplementedError();
  }

  void compFunCreation() {
    // Create some composite functions.
    throw new UnimplementedError();
  }
  
  void compFuncSimplification() {
    throw new UnimplementedError();
  }
  
  void compFuncDifferentiation() {
    throw new UnimplementedError();
  }

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
        return (expr as Variable).name == name;
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
      Expression expr = _simplify ? _simplifyExp((item as Expression)) : (item as Expression);
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