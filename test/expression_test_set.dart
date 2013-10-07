part of math_expressions_test;

/**
 * Contains methods to test the math expression implementation.
 */
class ExpressionTests extends TestSet {

  get name => 'Expression Tests';

  get testFunctions => {
    'Expression Creation [REAL]': simpleRealCreation,
    'Expression Creation [INTERVAL]': simpleIntervalCreation,
    'Expression Creation [VECTOR]': simpleVectorCreation,
    'Binary Op Convenience Creation': convenienceBinaryCreation,
    'Unary Op Convenience Creation': convenienceUnaryCreation,
    'Operator simplification': baseOperatorSimplification,
    'Operator differentiation': baseOperatorSimplification,
    'Simple evaluation [REAL]': simpleRealEval,
    'Simple evaluation [INTERVAL]': simpleIntervalEval,
    'Simple evaluation [VECTOR]': simpleVectorEval,
    'Default Function Creation': defFuncCreation,
    'Default Function simplification': defFuncSimplification,
    'Default Function differentiation': defFuncDifferentiation,
    'Default Function evaluation [REAL]': defFuncRealEval,
    'Default Function evaluation [INTERVAL]': defFuncIntervalEval,
    'Default Function evaluation [VECTOR]': defFuncVectorEval,
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

    //TODO vector
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
    /*
     * Plus
     */
    // TODO Implement a function matcher?
    throw new UnimplementedError();
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
    throw new UnimplementedError();
  }

  void defFuncRealEval() {
    throw new UnimplementedError();
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
}